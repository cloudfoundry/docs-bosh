This topic describes cloud properties for different resources created by the OpenStack CPI.

## AZs {: #azs }

Schema for `cloud_properties` section:

* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `east`.

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: east
```

---
## Networks {: #networks }

Schema for `cloud_properties` section used by dynamic network or manual network subnet:

* **net_id** [String, required]: Network ID containing the subnet in which the instance will be created. Example: `net-b98ab66e-6fae-4c6a-81af-566e630d21d1`.
* **security_groups** [Array, optional]: Array of security groups to apply for all VMs that are placed on this network. Defaults to security groups specified by `default_security_groups` in the global CPI settings unless security groups are specified on a resource pool/vm type for a VM. If security groups are specified on a resource pool and a network, the resource pool security groups takes precedence since CPI v34+. In older CPI versions prior v34, security groups can either be specified for a network or a resource pool.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    cloud_properties:
      net_id: net-b98ab66e-6fae-4c6a-81af-566e630d21d1
      security_groups: [my-sec-group]
```

Example of dynamic network:

```yaml
networks:
- name: default
  type: dynamic
  cloud_properties:
    net_id: net-b98ab66e-6fae-4c6a-81af-566e630d21d1
```

Example of vip network:

```yaml
networks:
- name: default
  type: vip
```

---
## Resource Pools / VM Types {: #resource-pools }

Schema for `cloud_properties` section:

* **instance_type** [String, required]: Type of the instance. Example: `m1.small`.
* **availability_zone** [String, required]: Availability zone to use for creating instances. Example: `east`.
* **security_groups** [Array, optional]: Array of security groups to apply for all VMs that are in this resource pool. Defaults to security groups specified by `default_security_groups` in the global CPI settings unless security groups are specified on one of the VM networks. If security groups are specified on a resource pool and a network, the resource pool security groups takes precedence since CPI v34+. In older CPI versions prior v34, security groups can either be specified for a network or a resource pool.
* **key_name** [String, optional]: Key pair name. Defaults to key pair name specified by `default_key_name` in the global CPI settings. Example: `bosh`.
* **scheduler_hints** [Hash, optional]: Data passed to the OpenStack Filter scheduler to influence its decision where new VMs can be placed. See [VM Anti-Affinity](vm-anti-affinity.md#openstack) for a detailed example. Example: `{ group: af09abf2-2283... }`
* **root_disk** [Hash, optional]: Custom root disk properties. Requires `boot_from_volume: true` either [globally](https://bosh.io/jobs/openstack_cpi?source=github.com/cloudfoundry-incubator/bosh-openstack-cpi-release#p=openstack.boot_from_volume) or locally in this VM Type to enable cinder-backed boot volumes. Available in v25+.
    * **size** [Integer, required]: Specifies the disk size in gigabytes.
* **loadbalancer_pools** [Array, optional]:  Array of Hashes defining LBaaSv2 pools to attach this instance to. Requires neutron LBaaSv2 extension and OpenStack Mitaka or newer. Available in v32+.
    * **name** [String, required]: The name of the LBaaSv2 loadbalancer pool
    * **port** [Integer, required]: The port exposed on the instance
* **boot\_from\_volume** [Boolean, optional]: Override global [`boot_from_volume`](https://bosh.io/jobs/openstack_cpi?source=github.com/cloudfoundry-incubator/bosh-openstack-cpi-release#p=openstack.boot_from_volume) to enable cinder-backed boot volumes for this VM Type. Available in v34+.

Example of an `m1.small` instance:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-openstack-kvm-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    instance_type: m1.small
    availability_zone: east
```

Example of an `m1.small` instance, attached to LBaaSv2 pool named 'my-lb-pool'. Instance exposes port 8080 and is locked down by specific security groups:

```yaml
resource_pools:
- name: web-workers
  network: default
  stemcell:
    name: bosh-openstack-kvm-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    instance_type: m1.small
    availability_zone: east
    security_groups: [bosh-vms, lb-accessible]
    loadbalancer_pools:
      - name: my-lb-pool
        port: 8080
```

Example of an `m1.small` instance with custom root disk size of 50GB:

```yaml
resource_pools:
- name: default
  network: default
  stemcell:
    name: bosh-openstack-kvm-ubuntu-trusty-go_agent
    version: latest
  cloud_properties:
    instance_type: m1.small
    availability_zone: east
    root_disk:
      size: 50
```

---
## Disk Pools / Disk Types {: #disk-pools }

Schema for `cloud_properties` section:

* **type** [String, optional]: Volume type as configured in your OpenStack installation. Example: `SSD`

Cinder volumes are created in the availability zone of an instance that volume will be attached.

Example of 10GB SSD disk:

```yaml
disk_pools:
- name: default
  disk_size: 10_240
  cloud_properties:
    type: SSD
```

---
## Global Configuration {: #global }

See [CPI job configuration](https://bosh.io/jobs/openstack_cpi?source=github.com/cloudfoundry-incubator/bosh-openstack-cpi-release) for details.

Schema:

* **default_volume_type** [String, optional]: sets volume type for persistent disks unless overridden in resource pool/VM Type. `cinder type-list` will return the available volume types. Example: `SSD`.

Example with Keystone V3:

```yaml
properties:
  openstack:
    auth_url: http://pistoncloud.com:5000/v3
    username: christopher
    api_key: QRoqsenPsNGX6
    project: Bosh
    domain: sample-domain
    region: RegionOne
    default_key_name: bosh
    default_security_groups: [bosh]
```

Example with Keystone V2 and default volume type `ceph`:

```yaml
properties:
  openstack:
    auth_url: http://pistoncloud.com:5000/v2.0
    username: christopher
    api_key: QRoqsenPsNGX6
    tenant: Bosh
    region: RegionOne
    default_key_name: bosh
    default_security_groups: [bosh]
    default_volume_type: ceph
```

---
## Example Cloud Config {: #cloud-config }

```yaml
azs:
- name: z1
  cloud_properties:
    availability_zone: east1
- name: z2
  cloud_properties:
    availability_zone: east2

vm_types:
- name: default
  cloud_properties:
    instance_type: small
- name: large
  cloud_properties:
    instance_type: large

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
      net_id: net-b98ab66e-6fae-4c6a-81af-566e630d21d1
  - range: 10.10.1.0/24
    gateway: 10.10.1.1
    az: z2
    dns: [8.8.8.8]
    cloud_properties:
      net_id: net-85940t48-8ffe-3c3a-81af-27d499ff9842
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: z1
  vm_type: large
  network: default
```
