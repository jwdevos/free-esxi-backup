# free-esxi-backup
This script can be used for making manual backups of a single VM. It is intended to use on ESXi hosts that use the free license. This script was based on Florian Grehl's example in this blog: https://www.virten.net/2016/04/backup-solutions-for-free-esxi/. The script leverages ESXi snapshots.

# How to use
The script comes with the file bck_config.cfg. Set the datastore path for the backup destination in this config file. To view the help, run this:
```./bck.sh -h```

# Disclaimer:
This script is NOT thoroughly tested. You can mess up your VM('s) and your host if something goes wrong.

Backup script for backing up single VM's from the ESXi shell.
