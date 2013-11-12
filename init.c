/* supervisor-extras: init.c
 *
 * Copyright (c) 2013 Michael Forney
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <sys/mount.h>
#include <sys/reboot.h>

#ifndef STARTUP_COMMAND
#   define STARTUP_COMMAND "/etc/rc"
#endif
#ifndef RECOVER_COMMAND
#   define RECOVER_COMMAND "/bin/bash"
#endif

#define COLOR_RED       31
#define COLOR_GREEN     32
#define WEIGHT_BOLD     1 << 8

#define info(fmt, ...) msg(stdout, COLOR_GREEN | WEIGHT_BOLD, fmt, ##__VA_ARGS__)

static char * const startup[] = { STARTUP_COMMAND, 0 };
static char * const recover[] = { RECOVER_COMMAND, 0 };

/* Message printing utilities */
void vmsg(FILE * out, int style, const char * fmt, va_list args)
{
    fprintf(out, "\e[%u;%um>>\e[0m ", style >> 8, style & 0xff);
    vfprintf(out, fmt, args);
}

void __attribute__((format(printf, 3, 4)))
    msg(FILE * out, int color, const char * fmt, ...)
{
    va_list args;

    va_start(args, fmt);
    vmsg(out, color, fmt, args);
    va_end(args);
    fputc('\n', out);
}

void __attribute__((noreturn, format(printf, 1, 2)))
    die(const char * fmt, ...)
{
    va_list args;

    va_start(args, fmt);
    vmsg(stderr, COLOR_RED | WEIGHT_BOLD, fmt, args);
    va_end(args);
    if (errno != 0)
        fprintf(stderr, ": %s\n", strerror(errno));

    msg(stderr, COLOR_RED, "Executing recover command `%s'\n", recover[0]);
    execv(recover[0], recover);
    exit(EXIT_FAILURE);
}

void finish(int signum)
{
    int cmd;

    switch (signum)
    {
        case SIGUSR1:
            cmd = RB_AUTOBOOT;
            break;
        case SIGUSR2:
            cmd = RB_POWER_OFF;
            break;
        default:
            return;
    }

    kill(-1, SIGTERM);
    sleep(1);
    kill(-1, SIGKILL);
    sync();
    reboot(cmd);

    die("reboot() failed");
}

int main()
{
    int ret;
    struct sigaction action = { .sa_handler = &finish };
    sigset_t set;

    sigfillset(&set);
    sigdelset(&set, SIGUSR1);
    sigdelset(&set, SIGUSR2);
    sigprocmask(SIG_SETMASK, &set, 0);
    sigaction(SIGUSR1, &action, 0);
    sigaction(SIGUSR2, &action, 0);

    switch (fork())
    {
        case 0:
            sigemptyset(&set);
            sigprocmask(SIG_SETMASK, &set, 0);
            info("Executing startup command `%s'", startup[0]);
            execv(startup[0], startup);
            die("execv() failed");
        case -1:
            die("fork() failed");
    }

    while (true)
        wait(0);
}

