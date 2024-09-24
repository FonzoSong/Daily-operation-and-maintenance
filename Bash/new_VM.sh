#!/bin/bash
#########################################################
# Function : create a new VM                            #
# Platform : RHEL9                                      #
# Version  : 1.0                                        #
# Date     : 2024-09-24                                 #    
# Author   : Fonzo.S                                    #
# Contact  : fonzo.s@outlook.com                        #
#########################################################


# set -x

# use qemu:///system
VIRSH_CMD="virsh -c qemu:///system"

# Testing available
if ! command -v virsh &> /dev/null
then
    echo "virsh command could not be found, please install libvirt."
    exit
fi

printf "Enter the name of the VM: "
read VM_NAME

printf "Enter the size of the VM in GB: "
read VM_SIZE

printf "Specify storage pool? (y/n): "
read SPECIFY_STORAGE_POOL

if [ "$SPECIFY_STORAGE_POOL" == "y" ]; then
    $VIRSH_CMD pool-list
    printf "Enter the name of the storage pool: "
    read VM_STORAGE_POOL
else
    VM_STORAGE_POOL="default"
fi

printf "Enter the number of CPUs: "
read VM_CPUS

printf "Enter the amount of RAM in GB: "
read VM_RAM

$VIRSH_CMD net-list
printf "Enter the name of the network: "
read VM_NETWORK

VM_NETWORKS=("$VM_NETWORK")

printf "Do you need more networks? (y/n): "
read NEED_MORE_NETWORK

if [ "$NEED_MORE_NETWORK" == "y" ]; then
    while true; do
        printf "Enter the name of the network: "
        read VM_NETWORK
        VM_NETWORKS+=("$VM_NETWORK")
        
        printf "Do you need more networks? (y/n): "
        read NEED_MORE_NETWORK
        if [ "$NEED_MORE_NETWORK" == "n" ]; then
            break
        fi
    done
fi

printf "Enter the path of the install image: "
read -e PATH_IMAGE

printf "\nCheck your settings:\n"
printf "VM name: $VM_NAME\n"
printf "VM size: ${VM_SIZE}GB\n"
printf "VM storage pool: $VM_STORAGE_POOL\n"
printf "VM CPUs: $VM_CPUS\n"
printf "VM RAM: ${VM_RAM}GB\n"
printf "VM networks: ${VM_NETWORKS[@]}\n"
printf "Path of the install image: $PATH_IMAGE\n"

printf "Do you want to continue? (y/n): "
read CONTINUE

if [ "$CONTINUE" == "n" ]; then
    exit
fi

printf "Creating VM...\n"
virsh create --name "$VM_NAME" --memory "$((VM_RAM * 1024))" --vcpus "$VM_CPUS" --disk size="$VM_SIZE" --network network="${VM_NETWORKS[@]}" --cdrom "$PATH_IMAGE"
