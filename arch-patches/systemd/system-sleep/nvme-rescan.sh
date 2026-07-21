#!/bin/sh

# Target address for nvme0n1
PCI_ADDR="0000:05:00.0"

if [ "$1" = "post" ]; then
    echo "Removing frozen NVMe state at $PCI_ADDR..."
    if [ -e "/sys/bus/pci/devices/$PCI_ADDR/remove" ]; then
        echo 1 > "/sys/bus/pci/devices/$PCI_ADDR/remove"
    fi
    sleep 1
    echo "Forcing a cold PCIe bus rebind..."
    echo 1 > /sys/bus/pci/rescan
fi
