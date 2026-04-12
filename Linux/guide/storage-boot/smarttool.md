# SMARTTool

{% code title="Install smartmontools" %}
```
dnf install -y smartmontools
```
{% endcode %}

## smartctl -h

{% code title="smartctl -h (help output)" %}
```
smartctl 7.2 2020-12-30 r5155 [x86_64-linux-5.14.0-427.33.1.el9_4.x86_64] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

Usage: smartctl [options] device

============================================ SHOW INFORMATION OPTIONS =====

  -h, --help, --usage
         Display this help and exit

  -V, --version, --copyright, --license
         Print license, copyright, and version information and exit

  -i, --info
         Show identity information for device

  --identify[=[w][nvb]]
         Show words and bits from IDENTIFY DEVICE data                (ATA)

  -g NAME, --get=NAME
        Get device setting: all, aam, apm, dsn, lookahead, security,
        wcache, rcache, wcreorder, wcache-sct

  -a, --all
         Show all SMART information for device

  -x, --xall
         Show all information for device

  --scan
         Scan for devices

  --scan-open
         Scan for devices and try to open each device

================================== SMARTCTL RUN-TIME BEHAVIOR OPTIONS =====

  -j, --json[=cgiosuvy]
         Print output in JSON or YAML format

  -q TYPE, --quietmode=TYPE                                           (ATA)
         Set smartctl quiet mode to one of: errorsonly, silent, noserial

  -d TYPE, --device=TYPE
         Specify device type to one of:
         ata, scsi[+TYPE], nvme[,NSID], sat[,auto][,N][+TYPE], usbcypress[,X], usbjmicron[,p][,x][,N], usbprolific, usbsunplus, sntjmicron[,NSID], sntrealtek, intelliprop,N[+TYPE], jmb39x[-q],N[,sLBA][,force][+TYPE], jms56x,N[,sLBA][,force][+TYPE], marvell, areca,N/E, 3ware,N, hpt,L/M/N, megaraid,N, aacraid,H,L,ID, cciss,N, auto, test

  -T TYPE, --tolerance=TYPE                                           (ATA)
         Tolerance: normal, conservative, permissive, verypermissive

  -b TYPE, --badsum=TYPE                                              (ATA)
         Set action on bad checksum to one of: warn, exit, ignore

  -r TYPE, --report=TYPE
         Report transactions (see man page)

  -n MODE[,STATUS], --nocheck=MODE[,STATUS]                     (ATA, SCSI)
         No check if: never, sleep, standby, idle (see man page)

============================== DEVICE FEATURE ENABLE/DISABLE COMMANDS =====

  -s VALUE, --smart=VALUE
        Enable/disable SMART on device (on/off)

  -o VALUE, --offlineauto=VALUE                                       (ATA)
        Enable/disable automatic offline testing on device (on/off)

  -S VALUE, --saveauto=VALUE                                          (ATA)
        Enable/disable Attribute autosave on device (on/off)

  -s NAME[,VALUE], --set=NAME[,VALUE]
        Enable/disable/change device setting: aam,[N|off], apm,[N|off],
        dsn,[on|off], lookahead,[on|off], security-freeze,
        standby,[N|off|now], wcache,[on|off], rcache,[on|off],
        wcreorder,[on|off[,p]], wcache-sct,[ata|on|off[,p]]

======================================= READ AND DISPLAY DATA OPTIONS =====

  -H, --health
        Show device SMART health status

  -c, --capabilities                                            (ATA, NVMe)
        Show device SMART capabilities

  -A, --attributes
        Show device SMART vendor-specific Attributes and values

  -f FORMAT, --format=FORMAT                                          (ATA)
        Set output format for attributes: old, brief, hex[,id|val]

  -l TYPE, --log=TYPE
        Show device log. TYPE: error, selftest, selective, directory[,g|s],
        xerror[,N][,error], xselftest[,N][,selftest], background,
        sasphy[,reset], sataphy[,reset], scttemp[sts,hist],
        scttempint,N[,p], scterc[,N,M], devstat[,N], defects[,N], ssd,
        gplog,N[,RANGE], smartlog,N[,RANGE], nvmelog,N,SIZE

  -v N,OPTION , --vendorattribute=N,OPTION                            (ATA)
        Set display OPTION for vendor Attribute N (see man page)

  -F TYPE, --firmwarebug=TYPE                                         (ATA)
        Use firmware bug workaround:
        none, nologdir, samsung, samsung2, samsung3, xerrorlba, swapid

  -P TYPE, --presets=TYPE                                             (ATA)
        Drive-specific presets: use, ignore, show, showall

  -B [+]FILE, --drivedb=[+]FILE                                       (ATA)
        Read and replace [add] drive database from FILE
        [default is +/etc/smartmontools/smart_drivedb.h
         and then    /usr/share/smartmontools/drivedb.h]

============================================ DEVICE SELF-TEST OPTIONS =====

  -t TEST, --test=TEST
        Run test. TEST: offline, short, long, conveyance, force, vendor,N,
                        select,M-N, pending,N, afterselect,[on|off]

  -C, --captive
        Do test in captive mode (along with -t)

  -X, --abort
        Abort any non-captive test on device

=================================================== SMARTCTL EXAMPLES =====

  smartctl --all /dev/sda                    (Prints all SMART information)

  smartctl --smart=on --offlineauto=on --saveauto=on /dev/sda
                                              (Enables SMART on first disk)

  smartctl --test=long /dev/sda          (Executes extended disk self-test)

  smartctl --attributes --log=selftest --quietmode=errorsonly /dev/sda
                                      (Prints Self-Test & Attribute errors)
  smartctl --all --device=3ware,2 /dev/sda
  smartctl --all --device=3ware,2 /dev/twe0
  smartctl --all --device=3ware,2 /dev/twa0
  smartctl --all --device=3ware,2 /dev/twl0
          (Prints all SMART info for 3rd ATA disk on 3ware RAID controller)
  smartctl --all --device=hpt,1/1/3 /dev/sda
          (Prints all SMART info for the SATA disk attached to the 3rd PMPort
           of the 1st channel on the 1st HighPoint RAID controller)
  smartctl --all --device=areca,3/1 /dev/sg2
          (Prints all SMART info for 3rd ATA disk of the 1st enclosure
           on Areca RAID controller)
```
{% endcode %}

## Scan for devices

{% code title="smartctl --scan" %}
```
smartctl --scan
/dev/sda -d scsi # /dev/sda, SCSI device
```
{% endcode %}

## Query all SMART information for /dev/sda

{% code title="smartctl --all /dev/sda (example output)" %}
```
smartctl --all /dev/sda
smartctl 7.2 2020-12-30 r5155 [x86_64-linux-5.14.0-427.33.1.el9_4.x86_64] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     VBOX HARDDISK
Serial Number:    VB911d6255-dc004aed
Firmware Version: 1.0
User Capacity:    21,474,836,480 bytes [21.4 GB]
Sector Size:      512 bytes logical/physical
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ATA/ATAPI-6 published, ANSI INCITS 361-2002
Local Time is:    Tue Sep 24 10:43:46 2024 KST
SMART support is: Unavailable - device lacks SMART capability.

A mandatory SMART command failed: exiting. To continue, add one or more '-T permissive' options.
```
{% endcode %}

## Show device identity information

{% code title="smartctl -i /dev/sda (example output)" %}
```
smartctl -i /dev/sda
smartctl 7.2 2020-12-30 r5155 [x86_64-linux-5.14.0-427.33.1.el9_4.x86_64] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     VBOX HARDDISK
Serial Number:    VB911d6255-dc004aed
Firmware Version: 1.0
User Capacity:    21,474,836,480 bytes [21.4 GB]
Sector Size:      512 bytes logical/physical
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ATA/ATAPI-6 published, ANSI INCITS 361-2002
Local Time is:    Tue Sep 24 10:44:52 2024 KST
SMART support is: Unavailable - device lacks SMART capability.
```
{% endcode %}
