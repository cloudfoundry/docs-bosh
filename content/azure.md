---
title: Microsoft Azure
---

# Microsoft Azure

The `azure` CPI can be used with [Microsoft Azure](https://azure.microsoft.com/).

 * Release: [cloudfoundry-incubator/bosh-azure-cpi-release](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues)
 * Slack: [cloudfoundry#bosh-azure-cpi](https://cloudfoundry.slack.com/messages/bosh-azure-cpi)


## Concepts

The following table maps BOSH concepts to their Azure-native equivalents.

| BOSH              | Microsoft Azure |
| ----------------- | --------------- |
| Availability Zone | [Availability Zone](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview) |
| Virtual Machine   | [Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes) |
| Network Subnet    | [Virtual Network Subnet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) |
| Virtual IP        | [Public IP](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses) |
| Persistent Disk   | [Disk Storage](https://azure.microsoft.com/en-us/services/storage/disks/) and [Managed Disks](https://azure.microsoft.com/en-us/services/managed-disks/) |
| Disk Snapshot     | [Managed Disk Snapshot](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview#managed-disk-snapshots) |
| Stemcell          |  |


## Feature Support


### Network

| Network Type | Support |
| ------------ | ------- |
| Manual       | Multiple networks per instance |
| Dynamic      | Multiple networks per instance |
| VIP          | Single network per instance |


### Encryption


#### Managed Disks

When using Managed Disks, encryption is automatically used by all disks and cannot be disabled. All aspects of the encryption are internally managed by Azure.

| Disk Type       | Encryption | Customer-managed Keys |
| --------------- | ---------- | --------------------- |
| Root Disk       | Required, default | Not Supported |
| Ephemeral Disk  | Required, default | Not Supported |
| Persistent Disk | Required, default | Not Supported |


#### Storage Accounts

When using Storage Accounts, encryption keys can be managed through the [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) to ensure disks are encrypted. There are no specific properties which need to be configured through CPI configuration.

| Disk Type       | Encryption | Customer-managed Keys |
| --------------- | ---------- | --------------------- |
| Root Disk       | Required, default | Supported |
| Ephemeral Disk  | Required, default | Supported |
| Persistent Disk | Required, default | Supported |

**Key Rotation** - encryption keys can be configured and rotated from within the Azure Portal ([learn more](https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption)), and Azure transparently handles re-encryption of data.


### Miscellaneous

| Feature   | Support |
| --------- | ------- |
| Multi-CPI | Not Supported |
