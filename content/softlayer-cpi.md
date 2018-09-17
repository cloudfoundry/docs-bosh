This topic describes cloud properties for different resources created by the SoftLayer CPI.

## AZs {: #azs }

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    datacenter: lon02
```

---
## Networks {: #networks }

Assume `10.1.2.3` is the bosh director IP.

Example of dynamic network (both public and private networks are available):

```yaml
networks:
- name: default
  type: dynamic
  subnets:
  - az: lon02
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    cloud_properties:
      vlan_ids: [524954, 524956]
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
      vlan_ids: [524954]
```

Example of manual network:

```yaml
networks:
- name: manual_network
  type: manual
  subnets:
  - range: 10.112.166.128/26
    gateway: 10.112.166.129
    azs: [z1, z2, z3]
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    reserved:
    - 10.112.166.128
    - 10.112.166.129
    - 10.112.166.130
    - 10.112.166.131
    static:
    - 10.112.166.132 - 10.112.166.162
    cloud_properties:
      vlan_ids: [524954, 524956]
- name: default      # Must define dynamic network in Softlayer
  type: dynamic
  subnets:
  - az: lon02
    dns: [10.1.2.3, 10.0.80.11, 10.0.80.12]
    cloud_properties:
      vlan_ids: [524954, 524956]
```

Currently SoftLayer CPI does not support vip network.

---
## VM Types / VM Extensions {: #resource-pools }

Schema for `cloud_properties` section:

* **domain** [String, required]: Name of the domain. Example: `softlayer.com`.
* **hostname_prefix** [String, required]: Prefix of the vm name. Example: `bosh-softlayer`. Please note that, for bosh director, this property is the full hostname, and for other VMs in deployments, a timestamp will be appended to the property value to make the hostname.
* **ephemeral_disk_size** [Integer, required]: Ephemeral disk size in gigabyte. Example: `100`.
* **cpu** [Integer, required]: Number of CPUs. Example: `4`.
* **memory** [Integer, required]: Memory in megabytes. Example: `8192`.
* **datacenter** [String, required]: Name of the datacenter. Example: `lon02`.
* **hourly_billing_flag** [Boolean, optional]: If the vm is hourly billing. Default is `false`.

Example:

```yaml
vm_types:
- name: vms
  cloud_properties:
    domain: softlayer.com
    cpu: 4
    ephemeral_disk_size: 100
    hostname_prefix: bosh-softlayer
    hourly_billing_flag: true
    memory: 8192
```

---
## Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **Iops** [Integer, optional]: input/output operations per second (IOPS) value. Example: `1000`. If it's not set, a medium IOPS value of the specified disk size will be chosen.
* **UseHourlyPricing** [Boolean, optional]: If the disk is hourly pricing. Default is `false`.

Example of 100GB disk:

```yaml
disk_types:
- name: disks
  disk_size: 100_000
  cloud_properties:
    iops: 3000
    snapshot_space: 20
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
  cloud_properties:
    datacenter: lon02

vm_types:
- name: compilation
  cloud_properties:
    cpu:  4
    memory:  8192
    ephemeral_disk_size: 100
    hourly_billing_flag: true
    hostname_prefix: sl-compilation-worker-
- name: sl-server
  cloud_properties:
    cpu:  4
    memory:  8192
    ephemeral_disk_size: 100
    hourly_billing_flag: true
    hostname_prefix: sl-

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
    vlan_ids: [524954, 524956]

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: compilation
  network: default
```

Please notice that when the VM hostname length is exactly 64, the deployment is failing due to ssh problem. This is SoftLayer’s limitation which can’t be fixed in a short term. We have a work around in the CPI that when the hostname with 64 characters is identified, a padding "-1" is appended to make it longer than 64.
