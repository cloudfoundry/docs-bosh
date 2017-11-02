---
title: vCloud CPI
---

This topic describes cloud properties for different resources created by the vCloud CPI.

## <a id='azs'></a> AZs

Currently CPI does not support any cloud properties for AZs.

Example:

```yaml
azs:
- name: z1
```

---
## <a id='networks'></a> Networks

Schema for `cloud_properties` section used by manual network subnet:

* **name** [String, required]: Name of vApp network in which instance will be created. Example: `VPC_BOSH`.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      name: VPC_BOSH
```

vCloud CPI does not support dynamic or vip networks.

---
## <a id='resource-pools'></a> Resource Pools / VM Types

Schema for `cloud_properties` section:

* **cpu** [Integer, required]: Number of CPUs. Example: `1`.
* **ram** [Integer, required]: RAM in megabytes. Example: `1024`.
* **disk** [Integer, required]: Ephemeral disk size in megabytes. Example: `10240`

Example of a VM with 1 CPU, 1GB RAM, and 10GB ephemeral disk:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-vcloud-esxi-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    cpu: 1
    ram: 1_024
    disk: 10_240
```

---
## <a id='disk-pools'></a> Disk Pools / Disk Types

Currently the CPI does not support any cloud properties for disks.

Example of 10GB disk:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
```

---
[Back to Table of Contents](index.html#cpi-config)
