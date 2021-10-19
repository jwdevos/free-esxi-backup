# free-esxi-backup
This script can be used for making manual backups of a single VM. It is intended to use on ESXi hosts that use the free license. This script was based on Florian Grehl's example in this blog: https://www.virten.net/2016/04/backup-solutions-for-free-esxi/. The script leverages ESXi snapshots and makes a thin provisioned copy to a specified destination datastore path.

For automated, scheduled backups, [ghettoVCB](https://github.com/lamw/ghettoVCB) is highly recommended. This manual script just fills a void for me when I want to make a quick backup of a VM.

# How to use
Place the script files (bck.sh and bck_config.cfg) in a sensible place. I created `/usr/local` for this. Don't forget to make the script executable:
```chmod +x ./bck.sh```

The script comes with the file bck_config.cfg. Set the datastore path for the backup destination in this config file. To view the help, run this:
```./bck.sh -h```

To make a backup of a VM, run this:
```./bck.sh -n web01```

The script runs in the shell session of the user, who will usually be connected via SSH. If the SSH sessions disconnects, the backup job will be terminated. Run the script like this to make it run in the background and have a chance that the job will finish even if the SSH session disconnects:
```setsid ./bck -n web01 &```

# Disclaimer:
This script is NOT thoroughly tested. You can mess up your VM('s) and your host if something goes wrong. Due to complications when managing snapshots with vim-cmd, using the script to make a backup of the VM will remove ALL snapshots, not just the snapshot created for the backup job.
