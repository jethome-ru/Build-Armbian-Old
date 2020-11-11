#!/bin/bash

FLASH_TOOL=cc2538-bsl.py
FIRMWARE_FILE=JH_2538_2592_ZNP_UART_20201010.bin
SERIAL_DEVICE=/dev/ttyAML2

# Configure GPIOs
if [ ! -d /sys/class/gpio/gpio507 ]; then
  echo "Configure RESET GPIO"
  echo 507 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio507/direction
fi

if [ ! -d /sys/class/gpio/gpio510 ]; then
  echo "Configure BOOT GPIO"
  echo 510 > /sys/class/gpio/export
  echo out > /sys/class/gpio/gpio510/direction
fi

# Switch to boot mode
echo "Switch to BOOT mode..."
echo 0 > /sys/class/gpio/gpio510/value
echo 1 > /sys/class/gpio/gpio507/value
sleep 1
echo 0 > /sys/class/gpio/gpio507/value

echo "Start flashing..."
python3 ${FLASH_TOOL} -p ${SERIAL_DEVICE} -e -w ${FIRMWARE_FILE}

echo "Done!"

