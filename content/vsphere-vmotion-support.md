This topic describes how storage vmotion:
* is used by bosh 
* or may affect bosh deployments when triggered independently of bosh 

## Bosh director using storage vmotion to move persistent disks across data stores

When updating to desired datastore for a deployment (see [Migrating Datastores](vsphere-migrate-datastores.md)), the vsphere cpi attempts to use vsphere storage vmotion to migrate data from source persistent disk to target persistent disk. This is significantly faster than the usual disk resize method in which the bosh agent is copying the data across disks using the `tar` command.

## Vsphere infrastructure pro-actively moving disks across data stores  

It is possible for an operator to proactively move disks across datastores without coordination with the bosh director. This may be done manually, through the vsphere api (potentially through community projects, see https://github.com/vmware-tanzu/vmotion-migration-tool-for-bosh-deployments ), or through vsphere storage DRS. This does not require VMs and bosh jobs to be stopped.

!!! note
    Storage DRS and vMotion can be used with bosh-vsphere-cpi v18+.

!!! warning
    If a VM was accidentally deleted after a disk was migrated via DRS or vMotion, BOSH may be unable to locate the disk.

Typically Storage DRS and vMotion moves attached persistent disks with the VM.
When doing so it renames attached disks and places them into moved VM folder (typically called `vm-<uuid>`).
Prior to bosh-vsphere-cpi v18, Storage DRS and vMotion were not supported since the CPI was unable to locate renamed disks.
Later versions of the CPI are able to locate disks migrated by vSphere as long as the disks are attached to the VMs.

As VMs are recreated, the CPI will move persistent disks out of VM folders so that they are not deleted with the VMs.
This procedure will happen automatically when VMs are deleted (in `delete_vm` CPI call) and when disks are detached (in `detach_disk` CPI call).

