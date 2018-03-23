---
title: Recovery from an ESXi Host Failure
---

<p class="note">Note: Do not follow this procedure if vSphere HA is enabled and bosh-vsphere-cpi is v30+; vSphere HA will automatically move all VMs from the failed host to other good hosts.</p>

This topic describes how to recreate VMs in the event of an ESXi host failure.
The BOSH Resurrector is unable to recreate a VM on a failed ESXi host without
manual intervention.
It can not recreate a VM until the VM has
been successfully deleted, and it can not delete the VM because
the ESXi host is unavailable.
The following steps will allow the Resurrector to recreate these VMs on a healthy host.

1. Manually remove the failed Host from its cluster to force removal of all VMs
  1. select the ESXi host from the cluster: **vCenter &rarr; Hosts and Clusters
&rarr; _datacenter_ &rarr; _cluster_**
  2. right-click the failed ESXi host
  3. select **Remove from Inventory**
2. Re-upload all stemcells currently in use by the director
  - `bosh stemcells`

      ```
      +------------------------------------------+---------------+---------+-----------------------------------------+
      | Name                                     | OS            | Version | CID                                     |
      +------------------------------------------+---------------+---------+-----------------------------------------+
      | bosh-vsphere-esxi-hvm-centos-7-go_agent  | centos-7      | 3184.1  | sc-bc3d762c-71a1-4e76-ae6d-7d2d4366821b |
      | bosh-vsphere-esxi-ubuntu-trusty-go_agent | ubuntu-trusty | 3192    | sc-46509b02-a164-4306-89de-99abdaffe8a8 |
      | bosh-vsphere-esxi-ubuntu-trusty-go_agent | ubuntu-trusty | 3202    | sc-86d76a55-5bcb-4c12-9fa7-460edd8f94cf |
      | bosh-vsphere-esxi-ubuntu-trusty-go_agent | ubuntu-trusty | 3262.4* | sc-97e9ba2d-6ae0-41d1-beea-082b6635e7cb |
      +------------------------------------------+---------------+---------+-----------------------------------------+
      ```
   - re-upload the in-use stemcells (the ones with asterisks ('*') next to their version) with the `--fix` flag, e.g.:

       ```
       bosh upload stemcell https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent?v=3262.4 --fix
       ```
6. Wait for the resurrector to recreate the VMs. Alternatively, force a recreate using `bosh cck`
   and choose the `Recreate` option for each missing VM
9. Clean-up: after the ESXi host has been recovered and added back to the cluster,
   preferably while it's in maintenance mode, delete stemcells and powered-off, stale VMs:
   * **vCenter &rarr; Hosts and Clusters
 &rarr; _datacenter_ &rarr; _cluster_**
   * select the recovered ESXi host
   * **Related Objects &rarr; Virtual Machines**
   * delete stale VMs (VMs whose name match this pattern: _vm-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx_)
   * delete stale stemcells (VMs whose name match this pattern: _sc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx_)
   * VMs and stemcells can be deleted by right-clicking on them, selecting **All vCenter Actions &rarr; Delete from Disk**

---
[Back to Table of Contents](index.md#cpi-config)

Previous: [vSphere HA](vsphere-ha.md)

Next: [Recovery from a vSphere Network Partitioning Fault](vsphere-network-partition.md)
