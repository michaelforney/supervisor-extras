# rc.local.d/udev.sh

(
    # Wait for udevd to start up
    wait_for_socket /run/udev/control
    udevadm trigger --type-subsystems --action=add
    udevadm trigger --type=devices --action=add
) &

