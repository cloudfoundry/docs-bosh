---
title: Google CPI
---

This topic describes cloud properties for different resources created by the Google CPI.

## <a id='azs'></a> AZs

Schema for `cloud_properties` section:

* **zone** [String, required]: [Zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones) to use for creating VMs. Example: `us-central1-f`.

Example:

```yaml
azs:
- name: z1
  cloud_properties:
    zone: us-central1-f
```

---
## <a id='networks'></a> Networks

Schema for `cloud_properties` section used by dynamic network or manual network subnet:

* **network_name** [String, optional]: The name of the [Network](https://cloud.google.com/compute/docs/networking#networks) used when creating VMs. Default: `default`. Example: `boshnet`.
* **subnetwork_name** [String, optional]: The name of the [Subnet Network](https://cloud.google.com/compute/docs/networking#subnet_network) the CPI will use when creating VMs. If the network is in legacy mode, do not set subnetwork name. If the network is in auto subnet mode, providing the subnetwork is optional. If the network is in custom subnet mode, then it's required.
* **ephemeral\_external\_ip** [Boolean, optional]: If VMs on this network must have an [ephemeral external IP](https://cloud.google.com/compute/docs/instances-and-network#externaladdresses). Default: `false`.
* **ip_forwarding** [Boolean, optional]: If VMs on this network must have [IP forwarding](https://cloud.google.com/compute/docs/networking#canipforward) enabled. Default: `false`.
* **tags** [Array, optional]: A list of [tags](https://cloud.google.com/compute/docs/instances/managing-instances#tags) to apply to the VMs, useful if you want to apply firewall or routes rules based on tags. Default: `[]`. Example: `[bosh, internal]`.

Example of manual network:

```yaml
networks:
- name: default
  type: manual
  subnets:
  - range: 10.10.0.0/24
    gateway: 10.10.0.1
    dns: [8.8.8.8, 8.8.4.4]
    azs: [z1, z2]
    cloud_properties:
      network_name: cf
      ephemeral_external_ip: true
      tags: [internal, concourse]
```

Example of dynamic network spanning two zones:

```yaml
networks:
- name: default
  type: dynamic
  subnets:
  - azs: [z1, z2]
    dns: [8.8.8.8, 8.8.4.4]
    cloud_properties:
      network_name: cf
      ephemeral_external_ip: true
      tags: [internal, concourse]
```

Example of vip network:

```yaml
networks:
- name: default
  type: vip
```

---
## <a id='vm-types'></a> VM Types

Schema for `cloud_properties` section:

* **machine_type** [String, required]: Predefined type of the [VM](https://cloud.google.com/compute/docs/machine-types). Required unless custom CPU and RAM values are set. Example: `n1-standard-2`.
* **cpu** [Integer, required]: Number of vCPUs the CPI will use when creating the instance. Required if not using predefined machine type. Example: `2`.
* **ram** [Integer, required]: Amount of memory the CPI will use when creating the instance. Required if not using predefined machine type. Example: `2048`.
* **root\_disk\_size\_gb** [Integer, optional]: The size (in GB) of the VM root disk. Default: `10`.
* **root\_disk\_type** [String, optional]: Disk type the CPI will use when creating the VM root disk.
* **target_pool** [String, optional]: Place VM into specified [target pool](https://cloud.google.com/compute/docs/load-balancing/network/target-pools). No default.
* **backend_service** [String, optional]: Place VM into specified [backend service](https://cloud.google.com/compute/docs/load-balancing/http/backend-service). VM will be placed into one of the backend service's instance groups that matches VM's zone. No default.
* **automatic_restart** [Boolean, optional]: If the instances should be [restarted automatically](https://cloud.google.com/compute/docs/instances/setting-instance-scheduling-options#autorestart) if they are terminated for non-user-initiated reasons. Provided by the GCE and different from the Resurrector. Default: `false`.
* **on\_host\_maintenance** [String, optional]: [Instance behavior](https://cloud.google.com/compute/docs/instances/setting-instance-scheduling-options#onhostmaintenance) on infrastructure maintenance that may temporarily impact instance performance. Possible values: `MIGRATE` or `TERMINATE`. Default: `MIGRATE`.
* **preemptible** [Boolean, optional]: If the VM should be [preemptible](https://cloud.google.com/preemptible-vms/). Default: `false`.
* **service_scopes** [Array, optional]: [Authorization scope](https://cloud.google.com/docs/authentication#oauth_scopes) names for your default service account that determine the level of access your VM has to other Google services. Default: `[]` (no scope is assigned to the VM by default).

Example of an `n1-standard-2` VM:

```yaml
vm_types:
- name: default
  cloud_properties:
    instance_type: n1-standard-2
    root_disk_size_gb: 20
    root_disk_type: pd-ssd
    service_scopes:
    - compute.readonly
    - devstorage.read_write
```

---
## <a id='disk-types'></a> Disk Types

Schema for `cloud_properties` section:

* **type** [String, optional]: Type of the [disk](https://cloud.google.com/compute/docs/disks/#overview): `pd-standard`, `pd-ssd`. Defaults to `pd-standard`.

Persistent disks are created in the zone of a VM that disk will be attached.

Example of 10GB disk:

```yaml
disk_types:
- name: default
  disk_size: 10_240
```

---
## <a id='global'></a> Global Configuration

The CPI can only talk to a single Google Compute Engine region.

See [all configuration options](https://bosh.io/jobs/google_cpi?source=github.com/cloudfoundry-incubator/bosh-google-cpi-release).

---
## <a id='cloud-config'></a> Example Cloud Config

```yaml
azs:
- name: z1
  cloud_properties: {zone: us-central1-f}
- name: z2
  cloud_properties: {zone: us-central1-a}

vm_types:
- name: default
  cloud_properties:
    machine_type: n1-standard-4
    root_disk_size_gb: 20
    root_disk_type: pd-ssd

disk_types:
- name: default
  disk_size: 3000

networks:
- name: default
  type: manual
  subnets:
  - range:   10.10.0.0/24
    gateway: 10.10.0.1
    dns:     [8.8.8.8, 8.8.4.4]
    azs:     [z1, z2]
    cloud_properties:
      network_name: cf
      ephemeral_external_ip: true
      tags: [internal, concourse]
- name: vip
  type: vip

compilation:
  workers: 3
  reuse_compilation_vms: true
  az: z1
  vm_type: default
  network: default
```

---
[Back to Table of Contents](index.html#cpi-config)
