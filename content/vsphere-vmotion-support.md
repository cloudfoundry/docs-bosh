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
