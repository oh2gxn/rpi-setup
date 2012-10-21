#!/bin/bash

### These things were done after installing Raspbian v. 18.6.2012
## Firmware update
#rpi-update
#reboot
## Raspbian v. 19.8.2012 (rpi_installer_08-19-12.zip) does not have rpi-update


### Some software
apt-get update
apt-get upgrade
apt-get install sudo

## GCC and other programming tools
apt-get install gcc libtool flex bison gdb build-essential git

## GNU emacs
apt-get install emacs23-nox emacs23-el python-mode




### Limit the size and number of log files in /var/log/ !
sed -i '' -e 's/rotate\ 4/rotate\ 2/' /etc/logrotate.conf
echo 'size 100k' >> /etc/logrotate.conf




### OpenGL ES 2.0: use the stuff in /opt/vc/include and /opt/vc/lib
#apt-get install libgles2-mesa libgles2-mesa-dev
echo '/opt/vc/lib' > /etc/ld.so.conf.d/vc.conf
ldconfig

## User privileges for graphics
#chmod a+rw /dev/vchiq
echo 'SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"' > /etc/udev/rules.d/10-vchiq-permissions.rules
usermod -a -G video janne




### xmonad window manager???
#apt-get install xmonad




### Some Bluetooth support
apt-get install libbluetooth3 btscanner bluez python-gobject

USE_HIDD=0
if [USE_HIDD]; then
## Option A: taking Bluetooth HID keyboard into use: hidd
apt-get install bluez-compat
#
hcitool dev
## hci0 00:15:83:15:A3:10
hidd --search # ssh, wired keyboard...
## <Press BT button on the NanoX keyboard>
## Connecting to device BA:7B:89:11:6E:7C
#
echo "HIDD_ENABLED=1" >> /etc/default/bluetooth
echo 'HIDD_OPTIONS="-i hci0 --connect BA:7B:89:11:6E:7C --server"' >> /etc/default/bluetooth
#echo hidp | tee -a /etc/modules

else
## Option B: some newer BT setup, if hidd obsolete
#apt-get install bluetooth bluez-utils blueman # will install X
## some old thing(?):
##sed -i '' -e 's/HID2HCI_ENABLED=0/HID2HCI_ENABLED=1/' /etc/default/bluetooth
#
hcitool dev
## Devices:
##   hci0 00:15:83:15:A3:10
hcitool scan
## Scanning ...
##   BA:7B:89:11:6E:7C   Macro Keyboard
bluez-simple-agent hci0 BA:7B:89:11:6E:7C
## RequestPinCode (/org/bluez/5799/hci0/dev_BA_7B_89_11_6E_7C)
## Enter PIN Code: 4321 # type in a pin code on rpi (ssh, wired keyboard...)
## type in the same pin code on NanoX
bluez-test-device trusted BA:7B:89:11:6E:7C yes
bluez-test-input connect BA:7B:89:11:6E:7C
#
## alternative(?):
#bluetooth-agent 4321
#rfcomm connect hci0 BA:7B:89:11:6E:7C
fi

