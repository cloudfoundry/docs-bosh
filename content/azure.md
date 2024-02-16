---
title: Microsoft Azure
---

# Microsoft Azure

The `azure` CPI can be used with [Microsoft Azure](https://azure.microsoft.com/).

 * Release: [cloudfoundry/bosh-azure-cpi-release](https://github.com/cloudfoundry/bosh-azure-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry/bosh-azure-cpi-release/issues)
 * Slack: [cloudfoundry#bosh-azure-cpi](https://cloudfoundry.slack.com/messages/bosh-azure-cpi)


## Concepts

The following table maps BOSH concepts to their Azure-native equivalents.

|       BOSH        |                  Microsoft Azure                   |
| ----------------- | -------------------------------------------------- |
| Availability Zone | [Availability Zone][azure_docs_azs]                |
| Virtual Machine   | [Virtual Machine][azure_docs_vm_sizes]             |
| Network Subnet    | [Virtual Network Subnet][azure_docs_vnets]         |
| Virtual IP        | [Public IP][azure_docs_pub_ips]                    |
| Persistent Disk   | [Disk Storage][azure_docs_disks] and [Managed Disks][azure_docs_managed_disks] |
| Disk Snapshot     | [Managed Disk Snapshot][azure_docs_disk_snapshots] |
| Stemcell          | Disk Storage Blobs and Managed Disk Blobs          |
| Agent Settings    | Config Drive; BOSH Registry                        |

[azure_docs_azs]: https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
[azure_docs_vm_sizes]: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
[azure_docs_vnets]: https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview
[azure_docs_pub_ips]: https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm#public-ip-addresses
[azure_docs_disks]: https://azure.microsoft.com/en-us/services/storage/disks/
[azure_docs_managed_disks]: https://azure.microsoft.com/en-us/services/managed-disks/
[azure_docs_disk_snapshots]: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview#managed-disk-snapshots

## Feature Support

The following sections describe some specific BOSH features supported by the
CPI.

### Network

The CPI supports multiple NICs being attached to a single VM.

| Network Type |            Support             |
| ------------ | ------------------------------ |
| Manual       | Multiple networks per instance |
| Dynamic      | Multiple networks per instance |
| VIP          | Single network per instance    |

### Encryption

#### Managed Disks

When using Managed Disks, encryption is automatically used by all disks and
cannot be disabled. All aspects of the encryption are internally managed by
Azure.

|    Disk Type    |    Encryption     | Customer-managed Keys |
| --------------- | ----------------- | --------------------- |
| Root Disk       | Required, default | Not Supported         |
| Ephemeral Disk  | Required, default | Not Supported         |
| Persistent Disk | Required, default | Not Supported         |

#### Storage Accounts

When using Storage Accounts, encryption keys can be managed through the
[Azure Key Vault][azure_keyvault] to ensure disks are encrypted. There are no
specific properties which need to be configured through CPI configuration.

|    Disk Type    |    Encryption     | Customer-managed Keys |
| --------------- | ----------------- | --------------------- |
| Root Disk       | Required, default | Supported             |
| Ephemeral Disk  | Required, default | Supported             |
| Persistent Disk | Required, default | Supported             |

**Key Rotation** - encryption keys can be configured and rotated from within
the Azure Portal ([learn more][azure_disk_encryption]), and Azure
transparently handles re-encryption of data.

[azure_keyvault]: https://azure.microsoft.com/en-us/services/key-vault/
[azure_disk_encryption]: https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption

### Miscellaneous

|              Feature              |             Support              |
| --------------------------------- | -------------------------------- |
| Multi-CPI                         | Not Supported                    |
| Native Disk Resize                | Not Supported                    |
| Generic VM Resource Configuration | Supported, [v33][azure_cpi_v33]+ |

[azure_cpi_v33]: https://github.com/cloudfoundry/bosh-azure-cpi-release/releases/tag/v33
