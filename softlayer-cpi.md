---
title: SoftLayer CPI
---

This topic describes cloud properties for different resources created by the SoftLayer CPI.

## AZs {: #azs }

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    Datacenter: { Name: lon02 }
```

---
## Networks {: #networks }

Example of dynamic network (both public and private networks are available):

```yaml
networks:
- name: default
  type: dynamic
  subnets:
  - az: z1
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    cloud_properties:
      PrimaryNetworkComponent:
         NetworkVlan:
            Id: 524956
      PrimaryBackendNetworkComponent:
         NetworkVlan:
            Id: 524954
```

Example of dynamic network (only private network is available):

```yaml
networks:
- name: default
  type: dynamic
  subnets:
  - az: z1
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    cloud_properties:
      PrivateNetworkOnlyFlag: true
      PrimaryBackendNetworkComponent:
         NetworkVlan:
             Id: 524954
```

Example of manual network:

```yaml
networks:
- name: manual_network
  type: manual
  subnets:
  - range: 10.112.166.128/26
    gateway: 10.112.166.129
    dns:
    - 10.1.2.3
    - 10.0.80.11
    - 10.0.80.12
    reserved:
    - 10.112.166.128
    - 10.112.166.129
    - 10.112.166.130
    - 10.112.166.131
    static:
    - 10.112.166.132 - 10.112.166.162
```

Currently SoftLayer CPI does not support vip network.

---
## Resource Pools / VM Types {: #resource-pools }

Schema for `cloud_properties` section:

* **Domain** [String, required]: Name of the domain. Example: `softlayer.com`.
* **VmNamePrefix** [String, required]: Prefix of the vm name. Example: `bosh-softlayer`. Please note that, for bosh director, this property is the full hostname, and for other VMs in deployments, a timestamp will be appended to the property value to make the hostname.
* **EphemeralDiskSize** [Integer, required]: Ephemeral disk size in gigabyte. Example: `100`.
* **StartCpus** [Integer, required]: Number of CPUs. Example: `4`.
* **MaxMemory** [Integer, required]: Memory in megabytes. Example: `8192`.
* **Datacenter** :
    * **Name** [String, required]: Name of the datacenter. Example: `lon02`.
* **HourlyBillingFlag** [Boolean, optional]: If the vm is hourly billing. Default is `false`. 

Example:

```yaml
resource_pools:
- name: vms
  network: default
  stemcell:
    url: light-bosh-stemcell-3169-softlayer-esxi-ubuntu-trusty-go_agent
  cloud_properties:
    Domain: softlayer.com
    VmNamePrefix: bosh-softlayer
    EphemeralDiskSize: 100
    StartCpus: 4
    MaxMemory: 8192
    Datacenter:
       Name: lon02
    HourlyBillingFlag: true
```

---
## Disk Pools / Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **Iops** [Integer, optional]: input/output operations per second (IOPS) value. Example: `1000`. If it's not set, a medium IOPS value of the specified disk size will be chosen.
* **UseHourlyPricing** [Boolean, optional]: If the disk is hourly pricing. Default is `false`.

Example of 100GB disk:

```yaml
disk_pools:
- name: disks
  disk_size: 100_000
  cloud_properties:
    Iops: 1000
    UseHourlyPricing: true
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
  cloud_properties:
    Datacenter: { Name: lon02  }

vm_types:
- name: compilation
  cloud_properties:
    Bosh_ip: 10.1.2.3
    StartCpus:  4
    MaxMemory:  8192
    EphemeralDiskSize: 100
    HourlyBillingFlag: true
    VmNamePrefix: sl-compilation-worker-
- name: sl-server
  cloud_properties:
    Bosh_ip: 10.1.2.3
    StartCpus:  4
    MaxMemory:  8192
    EphemeralDiskSize: 100
    HourlyBillingFlag: true
    VmNamePrefix: sl-

disk_types:
- name: default
  disk_size: 50_000
- name: large
  disk_size: 500_000

networks:
- name: default
  type: dynamic
  subnets:
  - az: z1
  - dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
  cloud_properties:
    PrimaryNetworkComponent:
       NetworkVlan:
          Id: 524956
    PrimaryBackendNetworkComponent:
       NetworkVlan:
          Id: 524954

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: compilation
  network: default
```

The ``Bosh_ip`` property specified under ``cloud_properties`` is used for SoftLayer CPI to differentiate the director and common vms. The one with cloud_property ``Bosh_ip`` is a common vm. The one without ``Bosh_ip`` is the director.

Please notice that when the VM hostname length is exactly 64, the deployment is failing due to ssh problem. This is SoftLayer’s limitation which can’t be fixed in a short term. We have a work around in the CPI that when the hostname with 64 characters is identified, a padding "-1" is appended to make it longer than 64.

---
[Back to Table of Contents](index.md#cpi-config)
