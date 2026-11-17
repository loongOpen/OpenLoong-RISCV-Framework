#!/system/bin/sh
set -eu
BASE=/data/apps/drivers
mkdir -p "$BASE/log"
exec >> "$BASE/log/load-drivers.log" 2>&1
printf '\n=== driver load: %s ===\n' "$(date)"
printf 'boot_id='; cat /proc/sys/kernel/random/boot_id
if [ "$(uname -r)" != 6.18.3 ]; then echo 'ERROR: kernel is not 6.18.3; refusing to load'; exit 1; fi
load_module() {
    if [ -d "/sys/module/$1" ]; then
        echo "SKIP: $1 already loaded"
    else
        echo "LOAD: $2"
        insmod "$BASE/modules/$2"
    fi
    [ -d "/sys/module/$1" ] || { echo "ERROR: $1 not present"; exit 1; }
}
load_module can can.ko
load_module can_dev can-dev.ko
load_module can_raw can-raw.ko
load_module flexcan flexcan.ko
load_module usbserial usbserial.ko
load_module ftdi_sio ftdi_sio.ko
for n in 0 1 2 3 4 5; do
    [ -d "/sys/class/net/can$n" ] || { echo "ERROR: can$n missing"; exit 1; }
done
ls /sys/class/net
# USB tty is optional: no USB device may be connected during boot.
for tty in /dev/ttyUSB*; do [ ! -e "$tty" ] || ls -l "$tty"; done
echo 'SUCCESS: all six driver modules loaded; CAN interfaces left for application configuration'
