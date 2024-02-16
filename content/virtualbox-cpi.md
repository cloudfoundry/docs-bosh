This topic describes cloud properties for different resources created by the [VirtualBox CPI](https://bosh.io/releases/github.com/cloudfoundry/bosh-virtualbox-cpi-release). VirtualBox CPI works with [vSphere ESXI stemcells](https://bosh.io/stemcells/bosh-vsphere-esxi-ubuntu-xenial-go_agent).

## Feature Support

The following sections describe some specific BOSH features supported by the CPI.

### Network

The CPI does not support multiple NICs being attached to a VM.

| Network Type |           Support           |
| ------------ | --------------------------- |
| Manual       | Single network per instance |
| Dynamic      | Single network per instance |
| VIP          | Not Supported               |

### Miscellaneous

|              Feature              |    Support    |
| --------------------------------- | ------------- |
| Multi-CPI                         | Not Supported |
| Native Disk Resize                | Not Supported |
| Generic VM Resource Configuration | Supported, [v27.0.0](https://github.com/cloudfoundry/bosh-google-cpi-release/releases/tag/v27.0.0)+ |

## AZs {: #azs }

Currently the CPI does not support any cloud properties for AZs.

Example:

```yaml
azs:
- name: z1
```

---
## Networks {: #networks }

Schema for `cloud_properties` section used by network subnet:

* **name** [String, optional]: Name of the VirtualBox network. When not
  specified (i.e. empty or null value), a new network of the specified type
  will be created. For convenience, when the specified network does not exist,
  the CPI will try to create one with that name (see the many caveats about
  this below). Example: `vboxnet0`.
* **type** [String, optional]: Type of the VirtualBox network. Supported
  values: `hostonly`, `bridged`, `natnetwork`.
  See [`VBoxManage modifyvm` networking settings][modifyvm_net_settings] for
  more info. Default: `hostonly`.

[modifyvm_net_settings]: https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm-networking

!!! Caveats on `hostonly` networking names
    When a `hostonly` network name si specified, but no such network exist,
    the diffetent version of the CPI will behave differently, depending on the
    VirtualBox version an operating system version.
    With CPI version 0.4.x or earlier, then only `vboxnet0` is accepted as a
    name for a network to create, and any other name will produce an error.
    When the `name` property is not specified, then it will default to
    `vboxnet0`.
    With version 0.5.x and later, the name of the created network may be
    specified with more freedom, with two dinstinct behaviors: VirtualBox v7+
    on macOS will create a `hostonlynet` honoring the specified name, whereas
    all Linux versions and macOS version 6.x (or earlier) will use the
    specified name as a guess for the name that VirtulBox will pick when
    creating the `hostonlyif` network (indeed those versions of VirtualBox are
    naming `hostonlyif` networks sequentially using the `vboxnetX` pattern
    where `X` is a digit, starting at 0). And whenever the guess is wrong, the
    CPI will produce an error.

Example of manual network:

```yaml
networks:
- name: private
  type: manual
  subnets:
  - range:   192.168.56.0/24
    gateway: 192.168.56.1
    dns:     [192.168.56.1]
    cloud_properties:
      name: vboxnet0
```

---
## VM Types / VM Extensions {: #vm-types }

Schema for `cloud_properties` section:

* **cpus** [Integer, optional]: Number of CPUs. Example: `1`. Default: `1`.
* **memory** [Integer, optional]: RAM in megabytes. Example: `1024`. Default:
  `512`.
* **ephemeral_disk** [Integer, optional]: Ephemeral disk size in megabytes.
  Example: `10240`. Default: `5000`.
* **paravirtprovider** [String, optional]: Paravirtual provider type. See
  [`VBoxManage modifyvm` General Settings][modifyvm_general_settings] for
  valid values. Default: `default`.
* **audio** [String, optional]: Audio type. See [`VBoxManage modifyvm` Other
  Hardware Settings][modifyvm_other_hardware] for valid values, e.g. `none`,
  `default`, `null`, `dsound`, `was`, `oss`, `alsa`, `pulse`, `coreaudio`.
  Default: `none`.

!!! Caveats on audio ........................................................
    Audio is expected to be broken with VirtualBox 7+ on macOS. Contributions
    are welcome.

[modifyvm_general_settings]: https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm-general
[modifyvm_other_hardware]: https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm-other-hardware

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
## Disk Types {: #disk-types }

Currently the CPI does not support any cloud properties for disks.

Example of 10GB disk:

```yaml
disk_types:
  - name: default
    disk_size: 10_240
```

---
## Global Configuration {: #global }

The CPI uses individual VirtualBox VMs and disks. Since the CPI can only talk to a single VirtualBox server it can only manage resources on a single machine.

Example of a CPI configuration:

```yaml
properties:
  host: 192.168.56.1
  username: ubuntu
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAr/c6pUbrq/U+s0dSU+Z6dxrHC7LOGDijv8LYN5cc7alYg+TV
    ...
    fe5h79YLG+gJDqVQyKJm0nDRCVz0IkM7Nhz8j07PNJzWjee/kcvv
    -----END RSA PRIVATE KEY-----

  agent:
    mbus: "https://mbus:mbus-password@0.0.0.0:6868"

  ntp:
    - 0.pool.ntp.org
    - 1.pool.ntp.org

  blobstore:
    provider: local
    path: /var/vcap/micro_bosh/data/cache
```

See the documentation for [the `virtualbox_cpi` job][virtualbox_cpi_job] for
more details.

[virtualbox_cpi_job]: https://bosh.io/jobs/virtualbox_cpi?source=github.com/cloudfoundry/bosh-virtualbox-cpi-release

---
## Example Cloud Config {: #cloud-config }

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
      - range: 192.168.56.0/24
        gateway: 192.168.56.1
        azs: [z1, z2]
        reserved: [192.168.56.6]
        dns: [192.168.56.1]
        cloud_properties:
          name: vboxnet0

compilation:
  workers: 2
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: default
```
