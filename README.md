# upk

Userland package manager for Linux, distro irrelevant.

Features:

- downloading binary packages directly from original upstream repos
- small footprints, all data stored under `~/upk.d/`

Usage:

```
Usage: upk.sh <action> [app_id]
   list                             : list available packages
   install|remove <app_id[s]> [-y]  : -y skip confirmation
   update         [app_id[s]] [-y]  : empty app_id means update all
   enable|disable <app_id[s]>       : enable/disable desktop entry and icon
   lock           <app_id[s]>       : prevent update and mark installed
   clean          [old]             : clean cache
   -h|--help
```

Change directories:

```
UPK_METAPKG_DIR=~/upkk/metapkgs
UPK_DATA_DIR=~/upk.dd
```
