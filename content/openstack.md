---
title: OpenStack
---

# OpenStack

The `openstack` CPI can be used with [OpenStack](https://www.openstack.org).

 * Release: [cloudfoundry-incubator/bosh-openstack-cpi-release](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/issues)
 * Slack: [cloudfoundry#openstack](https://cloudfoundry.slack.com/messages/openstack)


## Requirements

An OpenStack environment running one of the following supported releases:

  * [Mitaka](http://www.openstack.org/software/mitaka) (actively tested)
  * [Newton](http://www.openstack.org/software/newton) (actively tested)
  * [Ocata](http://www.openstack.org/software/ocata) (actively tested)
  * [Pike](http://www.openstack.org/software/pike) (actively tested)

And the following OpenStack services:

 * [Identity](https://www.openstack.org/software/releases/ocata/components/keystone):
   BOSH authenticates credentials and retrieves the endpoint URLs for other OpenStack services.
 * [Compute](https://www.openstack.org/software/releases/ocata/components/nova):
   BOSH boots new VMs, assigns floating IPs to VMs
 * [Image](https://www.openstack.org/software/releases/ocata/components/glance):
   BOSH stores stemcells using the Image service.
 * *(Optional)* [OpenStack Networking](https://www.openstack.org/software/releases/ocata/components/neutron):
   Provides network scaling and automated management functions that are useful when deploying complex distributed systems. **Note:** OpenStack networking is used as default as of v28 of the OpenStack CPI.
 * *(Optional)* [OpenStack Block Storage](https://www.openstack.org/software/releases/ocata/components/cinder):
   BOSH creates persistent volumes. While it is technically possible to use BOSH on OpenStack without block storage, you won't get persistent volumes without it.

## Concepts

The following table maps BOSH concepts to their OpenStack-native equivalents.

| BOSH | OpenStack |
| ---- | --------- |
| Availability Zone | [Availability Zone](https://www.mirantis.com/blog/the-first-and-final-word-on-openstack-availability-zones/) |
| Virtual Machine | [Instance](https://docs.openstack.org/nova/queens/user/launch-instances.html) |
| Instance Type | [Flavor](https://docs.openstack.org/nova/latest/user/flavors.html) |
| VM Config Metadata | BOSH Registry, [HTTP Metadata service](https://docs.openstack.org/nova/latest/user/metadata-service.html) or [Config Drive](https://docs.openstack.org/nova/queens/user/config-drive.html) |
| Network Subnet | [Subnet](https://docs.openstack.org/neutron/queens/admin/intro-os-networking.html) |
| Virtual IP | [Floating IP](https://docs.openstack.org/nova/queens/user/manage-ip-addresses.html) |
| Persistent Disk | [Volume](https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html) |
| Disk Snapshot | [Volume Snapshot](https://docs.openstack.org/cinder/latest/cli/cli-manage-volumes.html) |
| Stemcell | [Virtual Machine Image](https://docs.openstack.org/glance/queens/user/index.html) |


## Feature Support

The following sections describe some specific BOSH features supported by the CPI.


### Network

The CPI supports multiple NICs being attached to a single VM.


| Network Type | Support |
| ------------ | ------- |
| Manual | Multiple networks per instance |
| Dynamic | Single network per instance |
| VIP | Single network per instance |


### Miscellaneous

| Feature | Support |
| ------- | ------- |
| Multi-CPI | Supported, [v31](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/releases/tag/v31)+ |
| Native Disk Resize | Supported, [v33](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release/releases/tag/v33)+ |
