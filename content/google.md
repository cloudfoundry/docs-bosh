---
title: Google Cloud Platform
---

# Google Cloud Platform

The `google` CPI can be used with [Google Cloud Platform](https://cloud.google.com/).

 * Release: [cloudfoundry/bosh-google-cpi-release](https://github.com/cloudfoundry/bosh-google-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry/bosh-google-cpi-release/issues)
 * Slack: [cloudfoundry#bosh-gce-cpi](https://cloudfoundry.slack.com/messages/bosh-gce-cpi)


## Concepts

The following table maps BOSH concepts to their respective IaaS concept.

| BOSH | Google Cloud Platform |
| ---- | --------------------- |
| Availability Zone | [Zone](https://cloud.google.com/compute/docs/regions-zones/) |
| Virtual Machine | [Virtual Machine Instance](https://cloud.google.com/compute/docs/instances/) |
| VM Config Metadata | [Instance Metadata](https://cloud.google.com/compute/docs/storing-retrieving-metadata) |
| Network Subnet | [VPC Subnet](https://cloud.google.com/vpc/docs/vpc#vpc_networks_and_subnets) |
| Virtual IP | [Static External IP](https://cloud.google.com/compute/docs/ip-addresses/#reservedaddress) |
| Persistent Disk | [Persistent Disks](https://cloud.google.com/persistent-disk/) |
| Disk Snapshot | [Persistent Disk Snapshots](https://cloud.google.com/compute/docs/disks/create-snapshots) |
| Stemcell | [Compute Custom Image](https://cloud.google.com/compute/docs/images#custom_images) |


## Feature Support

The following sections describe some specific BOSH features supported by the CPI.


### Network

The CPI does not support multiple NICs being attached to a VM.

| Network Type | Support |
| ------------ | ------- |
| Manual | Single network per instance |
| Dynamic | Single network per instance |
| VIP | Single network per instance |


### Miscellaneous

| Feature | Support |
| ------- | ------- |
| Multi-CPI | Not Supported |
| Native Disk Resize | Not Supported |
| Generic VM Resource Configuration | Supported, [v27.0.0](https://github.com/cloudfoundry/bosh-google-cpi-release/releases/tag/v27.0.0)+ |
