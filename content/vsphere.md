---
title: VMware vSphere
---

# vSphere

The `vsphere` CPI can be used with [VMware vSphere](https://www.vmware.com/products/vsphere.html).

 * Release: [cloudfoundry/bosh-vsphere-cpi-release](https://github.com/cloudfoundry/bosh-vsphere-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry/bosh-vsphere-cpi-release/issues)
 * Slack: [cloudfoundry#bosh](https://cloudfoundry.slack.com/messages/bosh)

## Requirements

An environment running one of the following supported releases:

  * [vSphere 6.5](https://docs.vmware.com/en/VMware-vSphere/6.5/rn/vsphere-esxi-vcenter-server-65-release-notes.html)
  * [vSphere 6.7](https://docs.vmware.com/en/VMware-vSphere/6.7/rn/vsphere-esxi-vcenter-server-67-release-notes.html)
  * [vSphere 7.0](https://docs.vmware.com/en/VMware-vSphere/7.0/rn/vsphere-esxi-vcenter-server-70-release-notes.html)
  * [vSphere 8.0](https://docs.vmware.com/en/VMware-vSphere/8.0/rn/vmware-vsphere-80-release-notes/index.html)

NSX Support:

  * [NSX-V](https://docs.vmware.com/en/VMware-NSX-for-vSphere/index.html) (not actively tested)
  * [NSX-T 2.5](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.5.3/rn/VMware-NSX-T-Data-Center-253-Release-Notes.html)
  * [NSX-T 3.0](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.0/rn/VMware-NSX-T-Data-Center-303-Release-Notes.html)
  * [NSX-T 3.1](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.1/rn/VMware-NSX-T-Data-Center-3121-Release-Notes.html)
  * [NSX-T 4.0](https://docs.vmware.com/en/VMware-NSX/4.0/rn/vmware-nsx-4001-release-notes/index.html)

## Concepts

The following table maps BOSH concepts to their vSphere-native equivalents.

|       BOSH        |                     vSphere                      |
| ----------------- | ------------------------------------------------ |
| Availability Zone | [Clusters][clusters]/[Resource Pools][rsc_pools] |
| Virtual Machine   | [Virtual Machine][vms]                           |
| Network Subnet    | [Networking][networking] (Port Group)            |
| Persistent Disk   | [Virtual Hard Disk][disks]                       |
| Stemcell          | [Virtual Machine][vms]                           |
| Agent Settings    | CD-ROM Virtual Device ISO                        |

[clusters]: https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.monitoring.doc/GUID-A47D16C9-0B07-4DB8-BB79-D67DD97D5194.html?hWord=N4IghgNiBcIMYQK4GcAuBTATskBfIA
[rsc_pools]: https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.monitoring.doc/GUID-74D23242-B353-4267-8CC3-7800DD9BB92A.html
[vms]: https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-55238059-912E-411F-A0E9-A7A536972A91.html
[networking]: https://docs.vmware.com/en/VMware-vSphere/6.0/com.vmware.vsphere.networking.doc/GUID-35B40B0B-0C13-43B2-BC85-18C9C91BE2D4.html
[disks]: https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-79116E5D-22B3-4E84-86DF-49A8D16E7AF2.html

## Feature Support

The following sections describe some specific BOSH features supported by the
CPI.

### Network

The CPI supports multiple NICs being attached to a single VM.

| Network Type |            Support             |
| ------------ | ------------------------------ |
| Manual       | Multiple networks per instance |
| Dynamic      | Not Supported                  |
| VIP          | Not Supported                  |

### Encryption

vSphere supports disk encryption and customer-managed keys when managed
through policy configuration within the vCenter 6.5+
([learn more][vsphere_encryption]). For this functionality, encryption occurs
at the hypervisor level which is transparent to the VM. Once enabled within
vCenter, no additional configuration is required for the CPI.

[vsphere_encryption]: https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-A29066CD-8EF8-4A4E-9FC9-8628E05FC859.html

|    Disk Type    | Encryption |
| --------------- | ---------- |
| Root Disk       | Supported  |
| Ephemeral Disk  | Supported  |
| Persistent Disk | Supported  |

### Miscellaneous

|      Feature       |              Support               |
| ------------------ | ---------------------------------- |
| Multi-CPI          | Supported, [v34][vsphere_cpi_v34]+ |
| Native Disk Resize | Not Supported                      |
| Native Disk Update | Not Supported                      |

[vsphere_cpi_v34]: https://github.com/cloudfoundry/bosh-vsphere-cpi-release/releases/tag/v34
