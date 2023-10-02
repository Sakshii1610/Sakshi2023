#!/bin/bash

# Define vSphere variables
VCENTER_SERVER="https://your-vcenter-server"
VCENTER_USER="your-username"
VCENTER_PASS="your-password"
DATASTORE="your-datastore"
CLUSTER="your-cluster"
VM_NAME="new-vm-name"
VM_TEMPLATE="template-name"
NETWORK="network-name"

# Install govc if not already installed
if ! command -v govc &> /dev/null; then
  wget https://github.com/vmware/govmomi/releases/download/v0.27.0/govc_linux_amd64 -O /usr/local/bin/govc
  chmod +x /usr/local/bin/govc
fi

# Set vSphere credentials
govc about -u="$VCENTER_USER" -p="$VCENTER_PASS" -k=true

# Deploy the VM from template
govc vm.clone -vm="$VM_TEMPLATE" -on=false -link=true -dc="Datacenter" -ds="$DATASTORE" -c="$CLUSTER" -folder="/" "$VM_NAME"

# Customize VM (customize as needed)
govc vm.change -vm="$VM_NAME" -c 2 -m 2048
govc vm.disk.change -vm="$VM_NAME" -size 20G
govc vm.network.add -vm="$VM_NAME" -net="$NETWORK"
govc vm.power -on "$VM_NAME"

# Wait for the VM to finish customization
while true; do
  STATUS=$(govc vm.info -vm "$VM_NAME" -json | jq -r .VirtualMachines[0].Runtime.PowerState)
  if [ "$STATUS" == "poweredOn" ]; then
    break
  fi
  sleep 10
done

# Additional customizations or post-deployment tasks can be added here

echo "VM $VM_NAME has been deployed and powered on."
