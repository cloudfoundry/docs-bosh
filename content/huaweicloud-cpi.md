This topic describes cloud properties for different resources created by the HuaweiCloud CPI.
The Huaweicloud CPI is designed for user most familiar with the Huawei cloud concepts and it only used in [Huaweicloud](https://www.huaweicloud.com/).

## AZs {: #azs }

Schema for `cloud_properties` section:

* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `cn-north-1b`.

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: cn-north-1b
```

---
## Networks {: #networks }

Schema for `cloud_properties` section used by dynamic network or manual network subnet:

* **subnet_id** [String, required]: Subnet ID in which the instances will be created.
* **security_groups** [Array, optional]: Array of security group names or UUIDs to apply for all VMs that are placed on this subnet.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      subnet_id: 3c8632e2-d9ff-41b1-aa0c-d455557314a0
      security_groups: [huaweicloud-security-group]
```

Example of dynamic network:

```yaml
networks:
- name: default
  type: dynamic
  cloud_properties:
    subnet_id: 3c8632e2-d9ff-41b1-aa0c-d455557314a0
```


---
## VM Types / VM Extensions {: #resource-pools }

Schema for `cloud_properties` section:

* **instance_type** [String, required]: Type of the instance. Example: `s3.large.2`.
* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `cn-north-1b`.
* **security_groups** [Array, optional]: Array of security group names or UUIDs to apply for all VMs that are placed on this network. Defaults to security groups specified by `default_security_groups` in the global CPI settings unless security groups are specified on one of the VM networks. If security groups are specified on a resource pool and a network, the resource pool security groups takes precedence since CPI v34+. In older CPI versions prior v34, security groups can either be specified for a network or a resource pool. Security group UUIDs can be used since CPI v39+.
* **key_name** [String, optional]: Key pair name. Defaults to key pair name specified by `default_key_name` in the global CPI settings. Example: `bosh`.

Example of an `s3.large.2` instance:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-huaweicloud-kvm-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    instance_type: s3.large.2
    availability_zone: cn-north-1b
```

---
## Global Configuration {: #global }

Schema:

* **auth_url** [String, required]: URL of the Huaweicloud Identity endpoint to connect to. Example: cn-north-1 Region endpoint https://iam.cn-north-1.myhwclouds.com.
* **username** [String, required]: Huaweicloud user name and used to access the Registry.
* **password** [String, required]: Password to access the Registry.
* **tenant** [String, required]: Huaweicloud tenant name.
* **region** [String, required]: Huaweicloud region name. A region is a [geographical area](https://developer.huaweicloud.com/en-us/endpoint) where you can run your services. Example: cn-north-1
* **default_key_name** [String, optional]: Key pair name. Defaults to key pair name specified by `default_key_name` in the global CPI settings. Example: `bosh`.
* **default_security_groups** [Array, optional]:  Array of security group names or UUIDs to apply for all VMs that are placed on this network. Defaults to security groups specified by `default_security_groups` in the global CPI settings unless security groups are specified on a resource pool/vm type for a VM.

Example with HuaweiCloud message:

```yaml
auth_url: https://iam.cn-north-1.myhwclouds.com
username: test
password: test_password
tenant: test
region: cn-north-1
default_key_name: bosh
default_security_groups: [bosh]
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: cn-north-1a
- name: z2
  cloud_properties:
    availability_zone: cn-north-1b

vm_types:
- name: default
  cloud_properties:
    instance_type: s2.large.2
- name: large
  cloud_properties:
    instance_type: s2.xlarge.2

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
    dns: [8.8.8.8]
    cloud_properties:
      subnet_id: 3c8632e2-d9ff-41b1-aa0c-d455557314a0
  - range: 10.10.1.0/24
    gateway: 10.10.1.1
    az: z2
    dns: [8.8.8.8]
    cloud_properties:
      subnet_id: wu2b22e2-dl39-cl3m-340c-d4jdu839mda0
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default
```
