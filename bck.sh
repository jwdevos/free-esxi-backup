#!/bin/sh
# free-esxi-backup bck.sh 2021 Jaap de Vos
#
# This script makes a backup of the specified VM.
#
# The backup destination gets configured in bck_config.cfg.
#  The backup destination needs to be a datastore that the host can see.
#
# The script will create a thin provisioned version of the virtual backup disk.
# WARNING: Using this script will delete all snapshots on the targeted VM.
#  This is due to complications when working with vim-cmd for snapshot management.
#
# Run the script like this to make sure the job keeps running
#  if your SSH session disconnects:
# setsid ./bck.sh -n $vmname &

# Instantiating some variables
timestamp=$(date +"%Y%m%d-%H%M00")
vmname=""

# Reading the config file
source ./bck_config.cfg

# Reading the CLI arguments
while getopts hn: flag
do
  case "${flag}" in
    h)
      echo "##### Use -n $vmname to run this script."
      exit 1
      ;;
    n)
      vmname=${OPTARG}
      ;;
  esac
done

# Getting the VM ID using vim-cmd vmsvc/getallvms
vmid=$(vim-cmd vmsvc/getallvms | grep "${vmname}/${vmname}.vmx" | awk '{print $1}')

# Getting the VM datastore name using vim-cmd vmsvc/getallvms
dsname=$(vim-cmd vmsvc/getallvms | grep "${vmname}/${vmname}.vmx" | awk '{print $3}')
dsname=${dsname:1:-1}

# Checking if the VM backup source location exists
bck_src="/vmfs/volumes/${dsname}/${vmname}"
echo "##### Checking if backup source path exists"
if [ -d $bck_src ]
then
  echo "##### Backup source path found, moving on"
else
  echo "##### $bck_src not found, exiting"
  exit 1
fi
echo ""

# Creating backup path, checking if it exists afterwards
bck_dst="${bck_path}/${vmname}/${timestamp}"
echo "##### Creating backup directory"
mkdir -p $bck_dst
if [ -d $bck_dst ]
then
  echo "##### Backup destination directory created, moving on"
else
  echo "##### $bck_dst not found, exiting"
  exit 1
fi
echo ""

# Checking if source vmx exists, if so, copying
vmx_src="${bck_src}/${vmname}.vmx"
echo "##### Copying ${vmx_src}"
if [ -f $vmx_src ]
then
  cp $vmx_src ${bck_dst}/${vmname}.vmx
  echo "##### ${vmx_src} copied, moving on"
else
  echo "##### $vmx_src not found, exiting"
  exit 1
fi
echo ""

# Checking if source nvram exists, if so, copying
nvram_src="${bck_src}/${vmname}.nvram"
echo "##### Copying ${nvram_src}"
if [ -f $nvram_src ]
then
  cp $nvram_src ${bck_dst}/${vmname}.nvram
  echo "##### ${nvram_src} copied, moving on"
else
  echo "##### $nvram_src not found, exiting"
  exit 1
fi
echo ""

# Checking if source vmsd exists, if so, copying
vmsd_src="${bck_src}/${vmname}.vmsd"
echo "##### Copying ${vmsd_src}"
if [ -f $vmsd_src ]
then
  cp $vmsd_src ${bck_dst}/${vmname}.vmsd
  echo "##### ${vmsd_src} copied, moving on"
else
  echo "##### $vmsd_src not found, exiting"
  exit 1
fi
echo ""

# Creating a snapshot with a unique name to remove it later
snapshotname="${timestamp}-${vmname}-backup"
echo "##### Creating snapshot ${snapshotname}"
vim-cmd vmsvc/snapshot.create $vmid $snapshotname $snapshotname 0 0
echo "##### Snapshot created, moving on"
echo ""

# Copying the snapshot version of the virtual disk
vmdk_src="${bck_src}/${vmname}.vmdk"
vmdk_dst="${bck_dst}/${vmname}.vmdk"
echo "##### Copying ${vmdk_src}"
if [ -f $vmdk_src ]
then
  echo $vmdk_src
  echo $vmdk_dst
  echo "vmkfstools -i ${vmdk_src} ${vmdk_dst} -d thin"
  vmkfstools -i ${vmdk_src} ${vmdk_dst} -d thin
  echo "##### ${vmdk_src} copied, moving on"
else
  echo "##### $vmdk_src not found, exiting"
  exit 1
fi
echo ""

# Removing ALL snapshots
echo "##### Removing ALL snapshots for VM ${vmname}"
vim-cmd vmsvc/snapshot.removeall $vmid
echo "##### Snapshots removed, finished running backup script #####"
exit 0
