# upk

Linux user-end package manager

Features:

- downloading binary packages directly from original upstream repos
- small footprints, all data stored under `~/upk.d/`

Usage:

```
Usage: upk <action> [app_id]
   list                             : list available packages
   install|remove <app_id[s]> [-y]  : -y skip confirmation
   update         [app_id[s]] [-y]  : empty app_id means update all
   enable|disable <app_id>          : enable/disable desktop entry
   lock           <app_id>          : prevent update and mark installed
   clean          [old]             : clean cache
   -h|--help
```

Current supported packages is under `metapkgs` folder, you can write your own
and put into `~/upk.d/metapkgs/`.

