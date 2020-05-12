This topic describes cloud properties for different resources created by the Alibaba Cloud CPI.

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

* **vswitch_id** [String, required]: VSwitch ID in which the instance will be created. Example: `vsw-123456abc`.
* **security_group_ids** [Array, optional]: Array of [Security Groups](https://www.alibabacloud.com/help/doc-detail/25468.htm), to apply to all VMs placed on this network. Security groups can be specified as follows, ordered by greatest precedence: `vm_types`, followed by `networks`.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      vswitch_id: vsw-123456abc
      security_group_ids: [sg-abc12345]
```

Example of dynamic network:

```yaml
networks:
- name: default
  type: dynamic
  cloud_properties:
    vswitch_id: vsw-123456abc
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

* **instance_type** [String, required]: Type of the [instance](https://www.alibabacloud.com/help/doc-detail/25378.htm). Example: `ecs.g5.large`.
* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `us-east-1a`.
* **security_group_ids** [Array, optional]: See description under [networks](#networks). Available in v19+.
* **key\_pair\_name** [String, optional]: Key pair name. Example: `bosh`.
* **spot\_price\_limit** [Float, optional]: Bid price in RMB for Alibaba Cloud spot instance. Using this option will slow down VM creation. Example: `0.03`.
* **spot_strategy** [String, optional]: Sets an expected spot price if you are creating preemptible instances. It takes effect only when parameter InstanceChargeType is PostPaid. Options:
  * `NoSpot` A normal Pay-As-You-Go instance.
  * `SpotWithPriceLimit` Sets the price threshold for a preemptible instance.
  * `SpotAsPriceGo` A price that is based on the highest Pay-As-You-Go instance.

  Default value: NoSpot.
* **slbs** [Array, optional]: Array of Load balancer Ids that should be attached to created VMs. Example: `[lb-abc123456]`. Default is `[]`.
* **ram\_role\_name** [String, optional]: Instance RAM role name. The name is provided and maintained by RAM and can be queried using [ListRoles](https://www.alibabacloud.com/help/doc-detail/28713.htm).
 For more information, see [CreateRole](https://www.alibabacloud.com/help/doc-detail/28710.htm) and [ListRoles](https://www.alibabacloud.com/help/doc-detail/28713.htm). Example: `director`.
* **instance_name** [String, optional]: The instance name. It is a string of 2 to 128 English letters and special characters. It must begin with an English or a Chinese character.
It can contain digits, periods (.), colons (:), underscores (_), and hyphens (-), but cannot begin with http:// or https://.  The default value is the `InstanceId` of the instance.
* **passowrd** [String, optional]: Password of the ECS instance. It can be [8, 30] characters in length. It must contain uppercase and lowercase letters, digits. The following special characters are allowed: @ # $ % ^ & * - + = | { } [ ] : ; ‘ < > , . ? /
* **charge_type** [String, optional]: Billing methods. Optional values:
  * `PrePaid` Monthly, or annual subscription. Make sure that your registered credit card is invalid or you have insufficient balance in your PayPal account. Otherwise,  InvalidPayMethod error may occur.
  * `PostPaid` Pay-As-You-Go.

  Default value: PostPaid.
* **charge_period** [Integer, optional]: The charge period of `PrePaid` instance. The value depends on `charge_period_unit`.
* **charge\_period\_unit** [String, optional]: The charge period unit of `PrePaid` instance. Optional values: Week | Month. When PeriodUnit is Week, period can be one of {“1”, “2”, “3”, “4”}.
When PeriodUnit is Month, period can be one of { “1”, “2”, “3”, “4”, “5”, “6”, “7”, “8”, “9”, “12”, “24”, “36”,”48”,”60”}. Default value: Month.
* **auto_renew** [Boolean, optioal]: Whether to set AutoRenew. This parameter is valid when InstanceChargeType is PrePaid. Optional values:
  * `True` Enable automatic renewal.
  * `False` Disable automatic renewal.

  Default value: false.
* **auto\_renew\_period** [Integer, optional]: When AutoRenew is set to True, this parameter is required. When PeriodUnit is Week, AutoRenewPeriod can be one of {“1”, “2”, “3”}.
 When PeriodUnit is Month, AutoRenewPeriod can be one of {“1”, “2”, “3”, “6”, “12”}.

* **region** [String, optional]: Alibaba Cloud region id. Example: `us-east-1`. Available in v19+. Defaults to region specified by `region` in global CPI settings.
* **stemcell_id** [String, optioal]: The specified stemcell id used to launch instance. It can be used to cross-region deployment. Available in v19+.

* **ephemeral_disk** [Hash, optional]: Elastic block storage data disk of custom size. Default disk size is either the size of first instance storage disk.
    * **size** [Integer, required]: Specifies the disk size in megabytes.
    * **category** [String, optional]: category of the [Elastic block storage](https://www.alibabacloud.com/help/doc-detail/25383.htm): `cloud_efficiency`, `cloud_ssd`. Defaults to `cloud_efficiency`.
        * `cloud_efficiency` Ultra cloud disk.
        * `cloud_ssd` Cloud SSD.
    * **encrypted** [Boolean, optional] Enables encryption for the ephemeral disk. Defaults to `false`. Overrides the global `encrypted` property.
    * **delete\_with\_instance** [Boolean, optional] Whether a data disk is released along with the instance or not. Optional values:
        * `true` The disk is released with the instance.
        * `false` The disk is not released with the instance.
* **system_disk** [Hash, optional]: Elastic block storage system disk of custom size.
    * **size** [Integer, required]: Specifies the disk size in megabytes.
    * **category** [String, optional]: category of the [Elastic block storage](https://www.alibabacloud.com/help/doc-detail/25383.htm): `cloud_efficiency`, `cloud_ssd`. Defaults to `cloud_efficiency`.
        * `cloud_efficiency` Ultra cloud disk.
        * `cloud_ssd` Cloud SSD.

Example of an `ecs.g5.large` instance:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-alicloud-kvm-ubuntu-xenial-go_agent
    version: latest
  cloud_properties:
    instance_type: ecs.sn1ne.large
    availability_zone: us-east-1a
```

---
## Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **category** [String, optional]: category of the [Elastic block storage](https://www.alibabacloud.com/help/doc-detail/25383.htm): `cloud_efficiency`, `cloud_ssd`. Defaults to `cloud_efficiency`.
    * `cloud_efficiency` Ultra cloud disk.
    * `cloud_ssd` Cloud SSD.
* **encrypted** [Boolean, optional] Enables encryption for the ephemeral disk. Defaults to `false`. Overrides the global `encrypted` property.
* **delete\_with\_instance** [Boolean, optional] Whether a data disk is released along with the instance or not. Optional values:
    * `true` The disk is released with the instance.
    * `false` The disk is not released with the instance.

Elastic block storage volumes are created in the availability zone of an instance that volume will be attached.

Example of 10GB disk:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
  cloud_properties:
    category: cloud_efficiency
```

---
## Global Configuration {: #global }

The CPI can only talk to a single Alibaba Cloud region.

Schema:

* **access\_key\_id** [String, optional]: Accesss Key ID. Example: `AKI...`.
* **access\_key\_secret** [String, optional]: Access Key Secret. Example: `0kwh...`.
* **security_token** [String, optional]: Alicloud [Security Token Service](https://www.alibabacloud.com/help/doc-detail/66222.html). Example: `0nwicsere...`.
* **region** [String, required]: Alibaba Cloud region name. Example: `us-east-1`
* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `us-east-1a`.
* **encrypted** [Boolean, optional]: Turns on [ECS disk encryption](https://www.alibabacloud.com/help/doc-detail/59643.htm) for all VM's data disks. Defaults to `false`.

Example with hard-coded credentials:

```yaml
properties:
  alicloud:
    access_key_id: ACCESS-KEY-ID
    access_key_secret: ACCESS-KEY-SECRET
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
    instance_type: ecs.sn1ne.large
    ephemeral_disk: {size: 3000, category: cloud_ssd}
- name: large
  cloud_properties:
    instance_type: ecs.c5.large
    ephemeral_disk: {size: 30000, category: cloud_ssd}

disk_types:
- name: default
  disk_size: 3000
- name: large
  disk_size: 50_000

networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    az: z1
    static: [10.10.0.62]
    dns: [10.10.0.2]
    cloud_properties: {vswitch_id: vsw-f2744a86}
  - range: 10.10.64.0/24
    gateway: 10.10.64.1
    az: z2
    static: [10.10.64.121, 10.10.64.122]
    dns: [10.10.0.2]
    cloud_properties: {vswitch_id: vsw-eb8bd3ad}
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default
```
