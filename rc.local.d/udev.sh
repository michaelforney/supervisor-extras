# rc.local.d/udev.sh

(
    # Wait for udevd to start up
    while [[ ! -S /run/udev/control ]] ; do
        sleep 1
    done
    udevadm trigger --type-subsystems --action=add
    udevadm trigger --type=devices --action=add
) &

