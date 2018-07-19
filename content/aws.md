---
title: Amazon Web Services
---

# Amazon Web Services

The `aws` CPI can be used with [Amazon Web Services](https://aws.amazon.com/).

 * Release: [cloudfoundry-incubator/bosh-aws-cpi-release](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release)
 * Issues: [GitHub Issues](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/issues)
 * Slack: [cloudfoundry#bosh](https://cloudfoundry.slack.com/messages/bosh)


## Concepts

The following table maps BOSH concepts to their AWS-native equivalents.

| BOSH              | Amazon Web Services |
| ----------------- | ------------------- |
| Availability Zone | [Availability Zone](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html) |
| Virtual Machine   | [EC2 Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Instances.html) |
| Network Subnet    | [VPC Subnet](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) |
| Virtual IP        | [EC2 Elastic IP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) |
| Persistent Disk   | [EC2 EBS Volume](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumes.html) |
| Disk Snapshot     | [EC2 EBS Snapshot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSSnapshots.html) |
| Stemcell          | [EC2 Amazon Machine Image](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) |


## Feature Support


### Network

The AWS CPI does not currently support multiple NICs being attached to a VM.

| Network Type | Support |
| ------------ | ------- |
| Manual       | Single network per instance |
| Dynamic      | Single network per instance |
| VIP          | Single network per instance |


### Encryption

AWS supports encryption functionality through their [Key Management Service](https://aws.amazon.com/kms/) using both IaaS-managed or customer-managed keys. The `encrypted` and `kms_key_arn` settings can be set globally, or for specific disks and stemcells, to configure encryption settings.

| Platform | Disk Type       | Encryption | Customer-managed Keys |
| -------- | --------------- | ---------- | --------------------- |
| Linux    | Root Disk       | Supported, [v69](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/releases/tag/v69)+ | Supported |
| Linux    | Ephemeral Disk  | Supported, [v69](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/releases/tag/v69)+ | Supported |
| Linux    | Persistent Disk | Supported, [v69](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/releases/tag/v69)+ | Supported |
| Windows  | Root Disk       | Partially Supported (manual steps required) | n/a |
| Windows  | Ephemeral Disk  | Not Supported | n/a |
| Windows  | Persistent Disk | Not Supported | n/a |

**Key Rotation** - since the CPI does not have insight into keys being rotated within AWS Console or `aws` CLI commands, it is typically easiest to rotate keys by provisioning a new key and updating cloud properties to refer to the new ARN. Since cloud properties for a disk change, BOSH will create a new disk using the new key and migrate data onto the new disk.


### Miscellaneous

| Feature   | Support |
| --------- | ------- |
| Multi-CPI | Supported, [v61](https://github.com/cloudfoundry-incubator/bosh-aws-cpi-release/releases/tag/v61)+ |
