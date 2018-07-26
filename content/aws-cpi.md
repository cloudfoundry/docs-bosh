This topic describes cloud properties for different resources created by the AWS CPI.

## AZs {: #azs }

Schema for `cloud_properties` section:

* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `us-east-1a`.

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: us-east-1a
```

---
## Networks {: #networks }

Schema for `cloud_properties` section used by dynamic network or manual network subnet:

* **subnet** [String, required]: Subnet ID in which the instance will be created. Example: `subnet-9be6c3f7`.
* **security_groups** [Array, optional]: Array of [Security Groups](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html), by name or ID, to apply to all VMs placed on this network. Security groups can be specified as follows, ordered by greatest precedence: `vm_types`, followed by `networks`, followed by `default_security_groups`.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      subnet: subnet-9be6c3f7
      security_groups: [bosh]
```

Example of dynamic network:

```yaml
networks:
- name: default
  type: dynamic
  cloud_properties:
    subnet: subnet-9be6c6gh
```

Example of vip network:

```yaml
networks:
- name: default
  type: vip
```

---
## VM Types / VM Extensions {: #resource-pools }

Schema for `cloud_properties` section:

* **instance_type** [String, required]: Type of the [instance](http://aws.amazon.com/ec2/instance-types/). Example: `m3.medium`.
* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `us-east-1a`.
* **security_groups** [Array, optional]: See description under [networks](#networks). Available in v46+.
* **key_name** [String, optional]: Key pair name. Defaults to key pair name specified by `default_key_name` in global CPI settings. Example: `bosh`.
* **spot\_bid\_price** [Float, optional]: Bid price in dollars for [AWS spot instance](http://aws.amazon.com/ec2/purchasing-options/spot-instances/). Using this option will slow down VM creation. Example: `0.03`.
* **spot\_ondemand\_fallback** [Boolean, optional]: Set to `true` to use an on demand instance if a spot instance is not available during VM creation. Defaults to `false`. Available in v36.
* **elbs** [Array, optional]: Array of ELB names that should be attached to created VMs. Example: `[prod-elb]`. Default is `[]`.
* **lb\_target\_groups** [Array, optional]: Array of Load Balancer Target Groups to which created VMs should be attached. Example: `[prod-group1, prod-group2]`. Default is `[]`. Available in v63 or newer.
* **iam\_instance\_profile** [String, optional]: Name of an [IAM instance profile](aws-iam-instance-profiles.md). Example: `director`.
* **placement_group** [String, optional]: Name of a [placement group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html). Example: `my-group`.
* **tenancy** [String, optional]: VM [tenancy](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/dedicated-instance.html) configuration. Example: `dedicated`. Default is `default`.
* **auto\_assign\_public\_ip** [Boolean, optional]: Assigns a public IP address to the created VM. This IP is ephemeral and may change; use an [Elastic IP](networks.md#vip) instead for a persistent address. Defaults to `false`. Available in v55+.
* **advertised\_routes** [Array, optional]: Creates routes in an [AWS Route Table](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Route_Tables.html) with the created BOSH VM as the target. Requires IAM action `ec2:CreateRoute`, `ec2:DescribeRouteTables`, `ec2:ReplaceRoute`.
    * **table\_id** [String, required]: ID of the route table in which to create the route (e.g. `rt-abcdef123`).
    * **destination** [String, required]: Destination CIDR for the route. All traffic with a destination within this CIDR will be routed through the created BOSH VM.
* **raw\_instance\_storage** [Boolean, optional]: Exposes all available [instance storage via labeled disks](aws-instance-storage.md). Defaults to `false`.
* **source\_dest\_check** [Boolean, optional]: Specifies whether the instance must be the source or destination of any traffic it sends or receives. If set to `false`, the instance does *not* need to be the source or destination. Used for network address translation (NAT) boxes, frequently to communicate between VPCs. Defaults to `true`. Requires IAM action `ec2:ModifyInstanceAttribute`. Available in v59+.
* **ephemeral_disk** [Hash, optional]: EBS backed ephemeral disk of custom size. Default disk size is either the size of first instance storage disk, if the instance_type offers it, or 10GB. Before v53: Used EBS only if instance storage is not large enough or not available for selected instance type.
    * **size** [Integer, required]: Specifies the disk size in megabytes.
    * **type** [String, optional]: Type of the [disk](http://aws.amazon.com/ebs/details/): `standard`, `gp2`. Defaults to `gp2`.
        * `standard` stands for EBS magnetic drives
        * `gp2` stands for EBS general purpose drives (SSD)
        * `io1` stands for EBS provisioned IOPS drives (SSD)
    * **iops** [Integer, optional]: Specifies the number of I/O operations per second to provision for the drive.
        * Only valid for `io1` type drive.
        * Required when `io1` type drive is specified.
    * **encrypted** [Boolean, optional] Enables encryption for the EBS backed ephemeral disk. An error is raised, if the `instance_type` does not support it. Since v53. Defaults to `false`. Overrides the global `encrypted` property.
    * **kms\_key\_arn** [String, optional] The ARN of an Amazon KMS key to use when encrypting the disk.
    * **use\_instance\_storage** [Boolean, optional] Forces the usage of instance storage as ephemeral disk backing. Will raise an error, if the used `instance_type` does not have instance storage. Cannot be combined with any other option under `ephemeral_disk` or with `raw_instance_storage`. Since v53. Defaults to `false`.
* **root_disk** [Hash, optional]: EBS backed root disk of custom size.
    * **size** [Integer, required]: Specifies the disk size in megabytes.
    * **type** [String, optional]: Type of the [disk](http://aws.amazon.com/ebs/details/): `standard`, `gp2`. Defaults to `gp2`.
        * `standard` stands for EBS magnetic drives
        * `gp2` stands for EBS general purpose drives (SSD)
    * **iops** [Integer, optional]: Specifies the number of I/O operations per second to provision for the drive.
        * Only valid for `io1` type drive.
        * Required when `io1` type drive is specified.

Example of an `m3.medium` instance:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-aws-xen-hvm-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    instance_type: m3.medium
    availability_zone: us-east-1a
```

---
## Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **type** [String, optional]: Type of the [disk](http://aws.amazon.com/ebs/details/): `standard`, `gp2`. Defaults to `gp2`.
    * `standard` stands for EBS magnetic drives
    * `gp2` stands for EBS general purpose drives (SSD)
    * `io1` stands for EBS provisioned IOPS drives (SSD)
* **iops** [Integer, optional]: Specifies the number of I/O operations per second to provision for the drive.
    * Only valid for `io1` type drive.
    * Required when `io1` type drive is specified.
* **encrypted** [Boolean, optional]: Turns on [EBS volume encryption](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) for this persistent disk. VM root and ephemeral disk are not encrypted. Defaults to `false`. Overrides the global `encrypted` property.
* **kms\_key\_arn** [String, optional]: Encrypts the disk using an encryption key stored in the [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/). The format of the ID is `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`. Be sure to use the Key ID, not the Alias. If omitted the disk will be encrypted using the global `kms_key_arn` property. If, no global `kms_key_arn` is set will use your account's default `aws/ebs` encryption key.

EBS volumes are created in the availability zone of an instance that volume will be attached.

Example of 10GB disk:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
  cloud_properties:
    type: gp2
```

---
## Global Configuration {: #global }

The CPI can only talk to a single AWS region.

Schema:

* **credentials_source** [String, optional]: Selects credentials source between credentials provided in this configuration, or from an [IAM instance profile](aws-iam-instance-profiles.md). Default: `static`.
* **access\_key\_id** [String, optional]: Accesss Key ID. Example: `AKI...`.
* **secret\_access\_key** [String, optional]: Secret Access Key. Example: `0kwh...`.
* **default\_key\_name** [String, required]: Name of the [Key Pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) that will be applied to all created VMs. Example: `bosh`
* **default\_security\_groups** [Array, required]: See description under [networks](#networks).
* **default\_iam\_instance\_profile** [String, optional]: Name of the [IAM instance profile](aws-iam-instance-profiles.md) that will be applied to all created VMs. Example: `director`.
* **region** [String, required]: AWS region name. Example: `us-east-1`
* **max_retries** [Integer, optional]: The maximum number of times AWS service errors (500) and throttling errors (`AWS::EC2::Errors::RequestLimitExceeded`) should be retried. There is an exponential backoff in between retries, so the more retries the longer it can take to fail. Defaults to 2.
* **encrypted** [Boolean, optional]: Turns on [EBS volume encryption](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) for all VM's root (system), ephemeral and persistent disks. Defaults to `false`. Available in v67+.
!!! note EBS volume encryption doesn't work for windows stemcells due to an [AWS limitation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/CopyingAMIs.html#copy-ami-across-accounts), hence turning this on wouldn't encrypt EBS volumes associated with Windows VMs. 
* **kms\_key\_arn** [String, optional]: Encrypts the disks using an encryption key stored in the [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/). The format of the ID is `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`. Be sure to use the Key ID, not the Alias. If this property is omitted and `encrypted` is `true`, the disks will be encrypted using your account's default `aws/ebs` encryption key. Available in v67+.

See [all configuration options](https://bosh.io/jobs/cpi?source=github.com/cloudfoundry-incubator/bosh-aws-cpi-release).

Example with hard-coded credentials:

```yaml
properties:
  aws:
    access_key_id: ACCESS-KEY-ID
    secret_access_key: SECRET-ACCESS-KEY
    default_key_name: bosh
    default_security_groups: [bosh]
    region: us-east-1
```

Example when [IAM instance profiles](aws-iam-instance-profiles.md) are used:

```yaml
properties:
  aws:
    credentials_source: env_or_profile
    default_key_name: bosh
    default_security_groups: [bosh]
    default_iam_instance_profile: deployed-vm
    region: us-east-1
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
  cloud_properties: {availability_zone: us-east-1a}
- name: z2
  cloud_properties: {availability_zone: us-east-1b}

vm_types:
- name: default
  cloud_properties:
    instance_type: t2.micro
    ephemeral_disk: {size: 3000, type: gp2}
- name: large
  cloud_properties:
    instance_type: m3.large
    ephemeral_disk: {size: 30000, type: gp2}

disk_types:
- name: default
  disk_size: 3000
  cloud_properties: {type: gp2}
- name: large
  disk_size: 50_000
  cloud_properties: {type: gp2}

networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    az: z1
    static: [10.10.0.62]
    dns: [10.10.0.2]
    cloud_properties: {subnet: subnet-f2744a86}
  - range: 10.10.64.0/24
    gateway: 10.10.64.1
    az: z2
    static: [10.10.64.121, 10.10.64.122]
    dns: [10.10.0.2]
    cloud_properties: {subnet: subnet-eb8bd3ad}
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default
```
