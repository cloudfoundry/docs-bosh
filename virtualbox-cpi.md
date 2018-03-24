---
title: VirtualBox CPI
---

This topic describes cloud properties for different resources created by the [VirtualBox CPI](https://bosh.io/releases/github.com/cppforlife/bosh-virtualbox-cpi-release). VirtualBox CPI works with [vSphere ESXI stemcells](https://bosh.io/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent).

## AZs <a id='azs'></a>

Currently the CPI does not support any cloud properties for AZs.

Example:

```yaml
azs:
- name: z1
```

---
## Networks <a id='networks'></a>

Schema for `cloud_properties` section used by network subnet:

* **name** [String, required]: Name of the network. Example: `vboxnet0`. Default: `vboxnet0`.
* **type** [String, optional]: Type of the network. See [`VBoxManage modifyvm` networking settings](https://www.virtualbox.org/manual/ch08.html#idp46691722135120) for valid values. Example: `hostonly`. Default: `hostonly`.

Example of manual network:

```yaml
networks:
- name: private
  type: manual
  subnets:
  - range:   192.168.50.0/24
    gateway: 192.168.50.1
    dns:     [192.168.50.1]
    cloud_properties:
      name: vboxnet0
```

---
## VM Types <a id='vm-types'></a>

Schema for `cloud_properties` section:

* **cpus** [Integer, optional]: Number of CPUs. Example: `1`. Default: `1`.
* **memory** [Integer, optional]: RAM in megabytes. Example: `1024`. Default: `512`.
* **ephemeral_disk** [Integer, optional]: Ephemeral disk size in megabytes. Example: `10240`. Default: `5000`.
* **paravirtprovider** [String, optional]: Paravirtual provider type. See [`VBoxManage modifyvm` general settings](https://www.virtualbox.org/manual/ch08.html#idp46691713664256) for valid values. Default: `minimal`.

Example of a VM type:

```yaml
vm_types:
- name: default
  cloud_properties:
    cpus: 2
    memory: 2_048
    ephemeral_disk: 4_096
    paravirtprovider: minimal
```

---
## Disk Types <a id='disk-types'></a>

Currently the CPI does not support any cloud properties for disks.

Example of 10GB disk:

```yaml
disk_types:
- name: default
  disk_size: 10_240
```

---
## Global Configuration <a id='global'></a>

The CPI uses individual VirtualBox VMs and disks. Since the CPI can only talk to a single VirtualBox server it can only manage resources on a single machine.

Example of a CPI configuration:

```yaml
properties:
  host: 192.168.50.1
  username: ubuntu
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAr/c6pUbrq/U+s0dSU+Z6dxrHC7LOGDijv8LYN5cc7alYg+TV
    ...
    fe5h79YLG+gJDqVQyKJm0nDRCVz0IkM7Nhz8j07PNJzWjee/kcvv
    -----END RSA PRIVATE KEY-----

  agent: {mbus: "https://mbus:mbus-password@0.0.0.0:6868"}

  ntp:
  - 0.pool.ntp.org
  - 1.pool.ntp.org

  blobstore:
    provider: local
    path: /var/vcap/micro_bosh/data/cache
```

See [virtualbox_cpi job](https://bosh.io/jobs/virtualbox_cpi?source=github.com/cppforlife/bosh-virtualbox-cpi-release) for more details.

---
## <a id='cloud-config'>Example Cloud Config</a>

```yaml
azs:
- name: z1
- name: z2

vm_types:
- name: default

disk_types:
- name: default
  disk_size: 3000

networks:
- name: default
  type: manual
  subnets:
  - range: 192.168.50.0/24
    gateway: 192.168.50.1
    azs: [z1, z2]
    reserved: [192.168.50.6]
    dns: [192.168.50.1]
    cloud_properties:
      name: vboxnet0

compilation:
  workers: 2
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: default
```

---
[Back to Table of Contents](index.md#cpi-config)
