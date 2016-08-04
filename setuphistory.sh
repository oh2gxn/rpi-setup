
#!/bin/bash
#
# This script file documents the settings made on my Raspberry Pi
# after installing Raspbian v. 19.8.2012 (rpi_installer_08-19-12.zip) 
# with minimal setup.
# This is not intended to be run as such...
#
# Author: Janne Toivola

# Username
USERNAME='janne'

RPIREV=2 # Rasp.PI revision: 1 for 256MB model B, 2 for 512MB model B

## Set better memory split for 3D graphics, default split was 224/32
#SPLIT=128 # for video and advanced 3D, on 256MB Raspi
#SPLIT=192 # for video or simple 3D
#SPLIT=224 # for no video or 3D
## NOTE: this was the oldest way of doing it
#cp /boot/arm"$SPLIT"_start.elf /boot/start.elf
#
## Firmware update, NOTE: these were some old stuff
#rpi-update
#reboot
#
## The new version does not have rpi-update from Hexxeh
## https://raw.github.com/Hexxeh/rpi-update/master/rpi-update
#wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && chmod +x /usr/bin/rpi-update
#rpi-update
if [RPIREV = 1]; then
    GPUMEM=128
else
    GPUMEM=256 # or even 256 for 512MB Raspi...
fi
#echo "gpu_mem=$GPUMEM" >> /boot/config.txt
#reboot
# NOTE: there were also other settings in config.txt.
# http://elinux.org/RPiconfig
#
## Apparently, also raspi-config is gone
# apt-get install raspi-config curl
#
## Yet another way: Device Tree and /boot/config.txt
echo "dtparam=audio=on,i2c=on" >> /boot/config.txt
echo "dtoverlay=i2c-rtc,ds1307=on" >> /boot/config.txt
echo "dtdebug=on" >> /boot/config.txt
#reboot
#sudo vcdbg log msg
## NOTE: Any of the above is probably outdated by tomorrow!



### Some software
apt-get update
apt-get upgrade
apt-get install sudo

## GCC and other programming tools
apt-get install gcc libtool flex bison gdb build-essential git

## Python stuff
apt-get install python-numpy python-scipy python-opengl

## GNU emacs
apt-get install emacs23-nox emacs23-el emacs-goodies-el python-mode




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
usermod -a -G video $USERNAME





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




### X, XDM, and xmonad window manager
apt-get install xorg xdm xmonad

# mess some settings in the user's home directory
$HOME="/home/$USERNAME"

# use CapsLock as mod2, may or may not be required in xmonad
USE_CAPS_MOD=0
if [USE_CAPS_MOD]; then
    # NOTE: this doesn't seem to work
    cp .capslockmod.map $HOME/
    echo 'xmodmap .capslockmod.map' >> $HOME/.xsession
fi

# make sure you have the correct keyboard layout
# before getting frustrated with typing in the password
echo 'setxkbmap fi,ru' >> $HOME/.xsession
# another option: dpkg-reconfigure keyboard-configuration

# settings to make xmonad run after login
cp .xmonad/xmonad.hs $HOME/.xmonad/
xmonad --recompile
echo '$HOME/.xmonad/xmonad-arm-linux' >> $HOME/.xsession

### Some software to go with xmonad
# hsetroot for setting the wallpaper, urxvt terminal, slock for locking the screen
apt-get install hsetroot rxvt-unicode suckless-tools

# setup urxvt colors and fonts... maybe bigger default font..?
apt-get install fontconfig
cp .Xdefaults $HOME/

# This might help with virtual terminal
echo 'setfont /usr/share/consolefonts/Lat15-Terminus20x10.psf.gz' >> $HOME/.bashrc
# ...and this helps in displaying pdf files etc. with less
echo "LESSOPEN='|/usr/bin/lesspipe %s'"  >> $HOME/.bashrc



## Audio for bytebeat etc...
apt-get install alsa-base alsa-utils
# TODO: audio seems b0rken, blame Device Tree?



## RTC etc. I2C stuff, NOTE: possibly controlled automagically by Device Tree?
apt-get install i2c-tools libi2c-dev python-smbus
echo i2c-bcm2708 >> /etc/modules
echo i2c-dev >> /etc/modules
# reboot, check that DS1307 RTC module from Adafruit etc. is connected to P1 pins 3 & 4
if [RPIREV = 1]; then
    RTCBUS=0
else
    # Model B 2.0 uses SCA1, SCL1 for I2C
    RTCBUS=1
fi
i2cdetect -y $RTCBUS
# RTC in address 0x68
RTCADDR=0x68
# Load and use RTC set at boot
sed -i '' -e 's/exit\ 0/#RTC/' /etc/rc.local
echo "echo ds1307 $RTCADDR > /sys/class/i2c-adapter/i2c-$RTCBUS/new_device" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
echo rtc-ds1307 >> /etc/modules


## GPIO from shell: pin 17 -> opto isolator -> RCA jack
#echo 17  > /sys/class/gpio/export
#echo out > /sys/class/gpio/gpio17/direction
#echo 1   > /sys/class/gpio/gpio17/value  # ON
#echo 0   > /sys/class/gpio/gpio17/value  # OFF


## Some ham radio software...
apt-get install libhamlib-dev libhamlib2 libusb-dev

## Upgrade from Wheezy to Jessie (ignore LibreOffice and other desktop bloat)
## https://www.raspberrypi.org/forums/viewtopic.php?t=121880
#sed 's/wheezy/jessie/' /etc/apt/sources.list
#echo "deb http://archive.raspberrypi.org/debian jessie main ui" > /etc/apt/sources.list.d/raspi.list
#mkdir -p $HOME/.config/autostart
#apt-get update
#apt-get dist-upgrade # answer Yes to most of the changes
#reboot

## Some internet of stuff...
#apt-get install nodejs npm # Jessie has "node 0.10.29" and "npm 1.4.21", too old for particle-cli
curl -sL https://deb.nodesource.com/setup_0.12 | bash - # FIXME: ARMv7 binary, but RPi 1 is ARMv6!
apt-get install nodejs
npm install -g particle-cli # "particle-cli 1.11.0" needs at least "node 0.12"
#particle setup
