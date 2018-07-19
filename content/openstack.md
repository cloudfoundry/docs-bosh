---
title: OpenStack
---

# OpenStack

The `openstack` CPI can be used with [OpenStack](https://azure.microsoft.com/).

 * Release: [cloudfoundry-incubator/bosh-openstack-cpi-release](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/issues)
 * Slack: [cloudfoundry#bosh-azure-cpi](https://cloudfoundry.slack.com/messages/bosh-azure-cpi)


## Requirements

An OpenStack environment running one of the following supported releases:

 * [Liberty](http://www.openstack.org/software/liberty) (actively tested)
 * [Mitaka](http://www.openstack.org/software/mitaka) (actively tested)
 * [Newton](http://www.openstack.org/software/newton) (actively tested)

    !!! tip
        Juno has a [bug](https://bugs.launchpad.net/nova/+bug/1396854) that prevents BOSH to assign specific IPs to VMs. You have to apply a Nova patch to avoid this problem.

And the following OpenStack services:

 * [Identity](https://www.openstack.org/software/releases/ocata/components/keystone):
   BOSH authenticates credentials and retrieves the endpoint URLs for other OpenStack services.
 * [Compute](https://www.openstack.org/software/releases/ocata/components/nova):
   BOSH boots new VMs, assigns floating IPs to VMs, and creates and attaches volumes to VMs.
 * [Image](https://www.openstack.org/software/releases/ocata/components/glance):
   BOSH stores stemcells using the Image service.
 * *(Optional)* [OpenStack Networking](https://www.openstack.org/software/releases/ocata/components/neutron):
   Provides network scaling and automated management functions that are useful when deploying complex distributed systems. **Note:** OpenStack networking is used as default as of v28 of the OpenStack CPI. To disable the use of the OpenStack Networking project, see [using nova-networking](openstack-nova-networking.md).


## Concepts

The following table maps BOSH concepts to their OpenStack-native equivalents.

| BOSH              | OpenStack |
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
| Dynamic      | Single network per instance |
| VIP          | Single network per instance |


### Miscellaneous

| Feature   | Support |
| --------- | ------- |
| Multi-CPI | Supported, [v31](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/releases/tag/v31)+ |
