# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Mystic-Kernel
dev.string=@okta_10
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=jasmine
device.name2=jasmine_sprout
device.name3=wayne
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

# Keycheck
INSTALLER=$(pwd)
KEYCHECK=$INSTALLER/tools/keycheck
chmod 755 $KEYCHECK

choose() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

## AnyKernel boot install
dump_boot;

ui_print " "
ui_print "  ================================= "
ui_print "   USE VOLUME KEY TO CHOOSE OPTION  "
ui_print "   (+) VOLUME UP & (-) VOLUME DOWN  "
ui_print "  ================================= "

# Start select Haptic driver
if [ -z $HAPTIC ]; then
  FUNCTION=choose
  ui_print " "
  ui_print "  Choose which haptic driver: "
  ui_print "  + QPNP Haptic (For most roms) "
  ui_print "  - QTI Haptic (For a few roms) "
  ui_print " "
  if $FUNCTION; then
    HAPTIC=true
  else
    HAPTIC=false
  fi
else
  ui_print "- Option specified in zipname! "
fi

# If the kernel image and dtbs are separated in the zip
decompressed_image=/tmp/anykernel/kernel/Image
compressed_image=$decompressed_image.gz
# Concatenate all of the dtbs to the kernel
if $HAPTIC; then
  ui_print "  > QPNP Haptic selected"
  cat $compressed_image /tmp/anykernel/dtbs/qpnp/*.dtb > /tmp/anykernel/Image.gz-dtb;
else
  ui_print "  > QTI Haptic selected"
  cat $compressed_image /tmp/anykernel/dtbs/qti/*.dtb > /tmp/anykernel/Image.gz-dtb;
fi

ui_print " "
ui_print "- NOTE: If the vibration not working or bootloop issue after flashing, please reflash this kernel & select another option Haptic driver. "
# End select Haptic driver

# Start select wired headphone buttons mode
if [ -z $WIRED_BTN ]; then
  FUNCTION=choose
  ui_print " "
  ui_print "  Choose which headphone buttons mode: "
  ui_print "  + Alternative Mode (For a few roms) "
  ui_print "  - Default Mode (For most roms) "
  ui_print " "
  if $FUNCTION; then
    WIRED_BTN=true
  else
    WIRED_BTN=false
  fi
else
  ui_print "- Option specified in zipname! "
fi

# patching weird headphone buttons
if $WIRED_BTN; then
  ui_print "  > Alternative mode selected"
  patch_cmdline "androidboot.wiredbtnaltmode" "androidboot.wiredbtnaltmode=1"
else
  ui_print "  > Default mode selected"
  patch_cmdline "androidboot.wiredbtnaltmode" "androidboot.wiredbtnaltmode=0"
fi

ui_print " "
ui_print "- NOTE: If headphone buttons not working or response abnormal, please reflash this kernel & select another wired headphone buttons mode. "
# End select wired headphone buttons mode

# Start select cpu clock speed
if [ -z $CPUCLOCK ]; then
  FUNCTION=choose
  ui_print " "
  ui_print "  Choose which CPU clock speed: "
  ui_print "  + CPU clock 2.2 GHz "
  ui_print "  - CPU clock 1.8 GHz "
  ui_print " "
  if $FUNCTION; then
    CPUCLOCK=true
  else
    CPUCLOCK=false
  fi
else
  ui_print "- Option specified in zipname! "
fi

# patching cpu clock
if $CPUCLOCK; then
  ui_print "  > CPU clock 2.2 GHz selected"
  patch_cmdline "androidboot.cpuclockspeed" "androidboot.cpuclockspeed=1"
else
  ui_print "  > CPU clock 1.8 GHz selected"
  patch_cmdline "androidboot.cpuclockspeed" "androidboot.cpuclockspeed=0"
fi

ui_print " "
ui_print "- NOTE: For whyred & tulip default CPU clock speed is 1.8 GHz, for a26x & lavender default CPU clock speed is 2.2 GHz. "
# End select cpu clock speed

write_boot;
## end boot install


# shell variables
#block=vendor_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_boot patching
#reset_ak;


## AnyKernel vendor_boot install
#split_boot; # skip unpack/repack ramdisk since we don't need vendor_ramdisk access

#flash_boot;
## end vendor_boot install

