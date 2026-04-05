#!/bin/bash
# Remove Polaris GPU from PCI bus on suspend/resume

DEVICES=(
  "0000:05:00.1"
  "0000:05:00.0"
)

case "$1" in
  pre)
    for dev in "${DEVICES[@]}"; do
      if [ -e "/sys/bus/pci/devices/$dev/remove" ]; then
        echo 1 > "/sys/bus/pci/devices/$dev/remove"
      fi
    done
    ;;
  post)
    # Give the bus a moment to settle after resume
    sleep 1
    for dev in "${DEVICES[@]}"; do
      if [ -e "/sys/bus/pci/devices/$dev/remove" ]; then
        echo 1 > "/sys/bus/pci/devices/$dev/remove"
      fi
    done
    ;;
esac
