---
schema: true
---

# AWS Cloud Properties

## Availability Zone {: #az }

Schema for `cloud_properties` section used by Availability Zones.

### `availability_zone` {: #az.availability_zone }

Availability zone to use for creating instances.

 * *Use*: Required
 * *Type*: string
 * *Example*: `"us-east-1a"`

## Network {: #network }

Schema for `cloud_properties` section used by dynamic and manual network subnets.

### `security_groups` {: #network.security_groups }

Array of [Security Groups](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html), by name or ID, to apply to all VMs placed on this network. Security groups can be specified as follows, ordered by greatest precedence: `vm_types`, followed by `networks`, followed by `default_security_groups`.

 * *Use*: Optional
 * *Type*: array

### `subnet` {: #network.subnet }

Subnet ID in which the instance will be created.

 * *Use*: Required
 * *Type*: string

## Virtual Machine {: #vm }

Schema for `cloud_properties` section used by Resource Pools and VM Types.

### `advertised_routes` {: #vm.advertised_routes }

Creates routes in an [AWS Route Table](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Route_Tables.html) with the created BOSH VM as the target. Requires IAM action `ec2:CreateRoute`, `ec2:DescribeRouteTables`, `ec2:ReplaceRoute`.

 * *Use*: Optional
 * *Type*: array

### `auto_assign_public_ip` {: #vm.auto_assign_public_ip }

Assigns a public IP address to the created VM. This IP is ephemeral and may change; use an [Elastic IP](http://bosh.io/docs/networks/#vip) instead for a persistent address.

 * *Use*: Optional
 * *Type*: boolean
 * *Default*: `false`

### `elbs` {: #vm.elbs }

Array of ELB names that should be attached to created VMs.

 * *Use*: Optional
 * *Type*: array
 * *Default*: `[]`
 * *Example*: `[
  "prod-elb"
]`

### `ephemeral_disk` {: #vm.ephemeral_disk }

EBS backed ephemeral disk of custom size.

 * *Use*: Optional
 * *Type*: object

> #### `encrypted` {: #vm.ephemeral_disk.encrypted }
> 
> Enables encryption for the EBS backed ephemeral disk.
> 
>  * *Use*: Optional
>  * *Type*: boolean
>  * *Default*: `false`
> 
> #### `iops` {: #vm.ephemeral_disk.iops }
> 
> Specifies the number of I/O operations per second to provision for the drive.
> 
>  * *Use*: Optional
>  * *Type*: integer
> 
> #### `kms_key_arn` {: #vm.ephemeral_disk.kms_key_arn }
> 
> The ARN of an Amazon KMS key to use when encrypting the disk.
> 
>  * *Use*: Optional
>  * *Type*: string
> 
> #### `size` {: #vm.ephemeral_disk.size }
> 
> Specifies the disk size in megabytes.
> 
>  * *Use*: Required
>  * *Type*: integer
> 
> #### `type` {: #vm.ephemeral_disk.type }
> 
> Type of the [disk](http://aws.amazon.com/ebs/details/).
> 
>  * *Use*: Optional
>  * *Type*: string
>  * *Default*: `"standard"`
>  * *Supported Values*: `"standard"`, `"gp2"`, `"io1"`
> 
> #### `use_instance_storage` {: #vm.ephemeral_disk.use_instance_storage }
> 
> Forces the usage of instance storage as ephemeral disk backing.
> 
>  * *Use*: Optional
>  * *Type*: boolean
>  * *Default*: `false`
> 

### `iam_instance_profile` {: #vm.iam_instance_profile }

Name of an [IAM instance profile](http://bosh.io/docs/aws-iam-instance-profiles/).

 * *Use*: Optional
 * *Type*: string
 * *Example*: `"director"`

### `instance_type` {: #vm.instance_type }

Type of the [instance](http://aws.amazon.com/ec2/instance-types/).

 * *Use*: Required
 * *Type*: string
 * *Supported Values*: `"c1.medium"`, `"c1.xlarge"`, `"c3.large"`, `"c3.xlarge"`, `"c3.2xlarge"`, `"c3.4xlarge"`, `"c3.8xlarge"`, `"c4.large"`, `"c4.xlarge"`, `"c4.2xlarge"`, `"c4.4xlarge"`, `"c4.8xlarge"`, `"cc2.8xlarge"`, `"cg1.4xlarge"`, `"cr1.8xlarge"`, `"d2.xlarge"`, `"d2.2xlarge"`, `"d2.4xlarge"`, `"d2.8xlarge"`, `"g2.2xlarge"`, `"g2.8xlarge"`, `"hi1.4xlarge"`, `"hs1.8xlarge"`, `"i2.xlarge"`, `"i2.2xlarge"`, `"i2.4xlarge"`, `"i2.8xlarge"`, `"m1.small"`, `"m1.medium"`, `"m1.large"`, `"m1.xlarge"`, `"m2.xlarge"`, `"m2.2xlarge"`, `"m2.4xlarge"`, `"m3.medium"`, `"m3.large"`, `"m3.xlarge"`, `"m3.2xlarge"`, `"m4.10xlarge"`, `"m4.large"`, `"m4.xlarge"`, `"m4.2xlarge"`, `"m4.4xlarge"`, `"r3.large"`, `"r3.xlarge"`, `"r3.2xlarge"`, `"r3.4xlarge"`, `"r3.8xlarge"`, `"t1.micro"`, `"t2.nano"`, `"t2.micro"`, `"t2.small"`, `"t2.medium"`, `"t2.large"`, `"x1.32xlarge"`
 * *Example*: `"m3.medium"`

### `key_name` {: #vm.key_name }

Key pair name. Defaults to key pair name specified by `default_key_name` in global CPI settings.

 * *Use*: Optional
 * *Type*: string
 * *Example*: `"bosh"`

### `lb_target_groups` {: #vm.lb_target_groups }

Array of Load Balancer Target Groups to which created VMs should be attached.

 * *Use*: Optional
 * *Type*: array
 * *Example*: `[
  "prod-group1",
  "prod-group2"
]`

### `placement_group` {: #vm.placement_group }

Name of a [placement group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html).

 * *Use*: Optional
 * *Type*: string
 * *Example*: `"my-group"`

### `raw_instance_storage` {: #vm.raw_instance_storage }

Exposes all available [instance storage via labeled disks](http://bosh.io/docs/aws-instance-storage/).

 * *Use*: Optional
 * *Type*: boolean
 * *Default*: `false`

### `root_disk` {: #vm.root_disk }

EBS backed root disk of custom size.

 * *Use*: Optional
 * *Type*: object

> #### `size` {: #vm.root_disk.size }
> 
> Specifies the disk size in megabytes.
> 
>  * *Use*: Optional
>  * *Type*: integer
> 
> #### `type` {: #vm.root_disk.type }
> 
> Type of the [disk](http://aws.amazon.com/ebs/details/)
> 
>  * *Use*: Optional
>  * *Type*: string
>  * *Default*: `"standard"`
>  * *Supported Values*: `"standard"`, `"gp2"`, `"io1"`
> 

### `security_groups` {: #vm.security_groups }

 * *Use*: Optional
 * *Type*: array

### `source_dest_check` {: #vm.source_dest_check }

Specifies whether the instance must be the source or destination of any traffic it sends or receives. If set to `false`, the instance does not need to be the source or destination. Used for network address translation (NAT) boxes, frequently to communicate between VPCs. Requires IAM action `ec2:ModifyInstanceAttribute`.

 * *Use*: Optional
 * *Type*: boolean
 * *Default*: `true`

### `spot_bid_price` {: #vm.spot_bid_price }

Bid price in dollars for AWS spot instance. Using this option will slow down VM creation.

 * *Use*: Optional
 * *Type*: number
 * *Example*: `0.03`

### `spot_ondemand_fallback` {: #vm.spot_ondemand_fallback }

Set to true to use an on demand instance if a spot instance is not available during VM creation.

 * *Use*: Optional
 * *Type*: boolean
 * *Default*: `false`

### `tenancy` {: #vm.tenancy }

VM [tenancy](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/dedicated-instance.html) configuration.

 * *Use*: Optional
 * *Type*: string
 * *Default*: `"default"`
 * *Example*: `"dedicated"`

## Persistent Disk {: #disk }

Schema for `cloud_properties` section used by Persistent Disks.

### `encrypted` {: #disk.encrypted }

Enables encryption for the EBS backed ephemeral disk.

 * *Use*: Optional
 * *Type*: boolean
 * *Default*: `false`

### `iops` {: #disk.iops }

Specifies the number of I/O operations per second to provision for the drive.

 * *Use*: Optional
 * *Type*: integer

### `type` {: #disk.type }

Type of the disk

 * *Use*: Optional
 * *Type*: string
 * *Default*: `"standard"`
 * *Supported Values*: `"standard"`, `"gp2"`, `"io1"`

## Global Settings {: #config }

Schema for `cloud_properties` section used by Availability Zones.

### `access_key_id` {: #config.access_key_id }

Accesss Key ID.

 * *Use*: Optional
 * *Type*: string

### `credentials_source` {: #config.credentials_source }

Selects credentials source between credentials provided in this configuration, or from an [IAM instance profile](http://bosh.io/docs/aws-iam-instance-profiles/).

 * *Use*: Optional
 * *Type*: string
 * *Default*: `"static"`

### `default_iam_instance_profile` {: #config.default_iam_instance_profile }

Name of the [IAM instance profile](http://bosh.io/docs/aws-iam-instance-profiles/) that will be applied to all created VMs.

 * *Use*: Optional
 * *Type*: string

### `default_key_name` {: #config.default_key_name }

Name of the [Key Pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) that will be applied to all created VMs.

 * *Use*: Required
 * *Type*: string
 * *Example*: `"bosh"`

### `default_security_groups` {: #config.default_security_groups }

See description under networks.

 * *Use*: Required
 * *Type*: array

### `encrypted` {: #config.encrypted }

Turns on [EBS volume encryption](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html) for all VM's root (system), ephemeral and persistent disks.

 * *Use*: Optional
 * *Type*: boolean
 * *Default*: `false`

### `kms_key_arn` {: #config.kms_key_arn }

Encrypts the disks using an encryption key stored in the [AWS Key Management Service (KMS)](https://aws.amazon.com/kms/). The format of the ID is `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`. Be sure to use the Key ID, not the Alias. If this property is omitted and `encrypted` is `true`, the disks will be encrypted using your account's default `aws/ebs` encryption key.

 * *Use*: Optional
 * *Type*: boolean

### `max_retries` {: #config.max_retries }

The maximum number of times AWS service errors (500) and throttling errors (`AWS::EC2::Errors::RequestLimitExceeded`) should be retried. There is an exponential backoff in between retries, so the more retries the longer it can take to fail.

 * *Use*: Optional
 * *Type*: number
 * *Default*: `2`

### `region` {: #config.region }

AWS region name.

 * *Use*: Required
 * *Type*: string
 * *Example*: `"us-east-1"`

### `secret_access_key` {: #config.secret_access_key }

Secret Access Key.

 * *Use*: Optional
 * *Type*: string

