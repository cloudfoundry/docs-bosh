---
title: VMware vCloud
---

# VMware vCloud

The `vcloud` CPI can be used with [VMware vCloud](https://www.vmware.com/products/vcloud-suite.html).

 * Release: [cloudfoundry-incubator/bosh-vcloud-cpi-release](https://github.com/cloudfoundry-incubator/bosh-vcloud-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry-incubator/bosh-vcloud-cpi-release/issues)
 * Slack: [cloudfoundry#bosh](https://cloudfoundry.slack.com/messages/bosh)


## Concepts

The following table maps BOSH concepts to their respective IaaS concept.

| BOSH              | Google Cloud Platform |
| ----------------- | --------------------- |
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


### Miscellaneous

| Feature   | Support |
| --------- | ------- |
| Multi-CPI | Not Supported |
