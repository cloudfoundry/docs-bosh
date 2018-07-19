---
title: VMware vSphere
---

# vSphere

The `vsphere` CPI can be used with [VMware vSphere](https://www.vmware.com/products/vsphere.html).

 * Release: [cloudfoundry-incubator/bosh-vsphere-cpi-release](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release/issues)
 * Slack: [cloudfoundry#bosh](https://cloudfoundry.slack.com/messages/bosh)


## Concepts

The following table maps BOSH concepts to their vSphere-native equivalents.

| BOSH              | vSphere |
| ----------------- | --------- |
| Availability Zone |  |
| Virtual Machine   |  |
| Network Subnet    |  |
| Virtual IP        |  |
| Persistent Disk   |  |
| Disk Snapshot     |  |
| Stemcell          |  |


## Feature Support


### Network

| Network Type | Support |
| ------------ | ------- |
| Manual       | Multiple networks per instance |
| Dynamic      | Not Supported |
| VIP          | Not Supported |


### Encryption

vSphere supports disk encryption and customer-managed keys when managed through policy configuration within the vCenter 6.5+ ([learn more](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-047A06F6-DE3D-4428-998C-DAAE84A33316.html). For this functionality, encryption occurs at the hypervisor level which is transparent to the VM. Once enabled within vCenter, no additional configuration is required for the CPI.

| Disk Type       | Encryption |
| --------------- | ---------- |
| Root Disk       | Supported |
| Ephemeral Disk  | Supported |
| Persistent Disk | Supported |


### Miscellaneous

| Feature   | Support |
| --------- | ------- |
| Multi-CPI | Not Supported |
