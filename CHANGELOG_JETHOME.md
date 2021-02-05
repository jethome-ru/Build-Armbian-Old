## 1.0.15 (2021-02-05)
* Disable and remove swap and revert zram on j100

## 1.0.14 (2021-02-03)
* Fix not working utility get_cpuid on j80/j100

## 1.0.13 (2021-02-01)
* Increase amount of available RAM memory from kernel by 128MB on j80
* Reduce cma-reserved memory 256MB => 4MB on j80/j100

## 1.0.12 (2021-01-29)
* Fix not-detecting of 1GB DDR RAM by bootloader on j100

## 1.0.11 (2021-01-27)
* Fix bluetooth starting failure after device reboot

## 1.0.10 (2021-01-26)
* Update platform specific hardware initialization on j80

## 1.0.9 (2021-01-21)
* Fix double IP address assignment

## 1.0.8 (2021-01-21)
* Add serial efuse key to bootloader on j80

## 1.0.7 (2020-12-03)
* Add platform specific hardware initialization on j100

## 1.0.6 (2020-11-27)
* Increase Swap file size to allow Home Assistant Supervised be started

## 1.0.5 (2020-11-13)
* Fix random network connection death on j100

## 1.0.4 (2020-11-12)
* Add package python3-pip
* Add pip3 packages: intelhex, pyserial, python-magic

## 1.0.3 (2020-10-26)
* Exclude hostapd from installed packages to avoid syslog cluttering
* Fix 100% memory use of /var/log

## 1.0.2 (2020-10-05)
* Do re-partition: leave only two partitions: boot (512MB) and rootfs (6.64 Gb)
* Return disappeared package linux-u-boot-arm-64-current

## 1.0.1 (2020-10-02)
* Enable updating from usb drive at boot if usb drive with jethome_burn.ini and img files is inserted

## 1.0.0 (2020-09-30)
* Add JetHome versioning
* Add CHANGELOG_JETHOME.md file
