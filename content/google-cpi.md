This topic describes cloud properties for different resources created by the Google CPI.

## AZs {: #azs }

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
## Networks {: #networks }

Schema for `cloud_properties` section used by dynamic network or manual network subnet:

* **network\_name** (String, optional) - The name of the [Google Compute Engine Network](https://cloud.google.com/compute/docs/networking#networks) the CPI will use when creating the instance (if not set, by default it will use the `default` network). Example: `cf`.
* **xpn\_host\_project\_id** (String, optional) - The [project id](https://support.google.com/cloud/answer/6158840?hl=en) that owns the network resource to support [Shared VPC Networks (XPN)](https://cloud.google.com/compute/docs/xpn/) (if not set, it will default to the project hosting the compute resources). Example: `my-other-project`.
* **subnetwork\_name** (String, optional) - The name of the [Google Compute Engine Subnet Network](https://cloud.google.com/compute/docs/networking#subnet_network) the CPI will use when creating the instance. If the network is in legacy mode, do not provide this property. If the network is in auto subnet mode, providing the subnetwork is optional. If the network is in custom subnet mode, then this field is required. Example: `cf-east`.
* **ephemeral\_external\_ip** (Boolean, optional) - If instances must have an [ephemeral external IP](https://cloud.google.com/compute/docs/instances-and-network#externaladdresses) (`false` by default). Can be overridden in resource_pools. Example: `false`.
* **ip\_forwarding** (Boolean, optional) - If instances must have [IP forwarding](https://cloud.google.com/compute/docs/networking#canipforward) enabled (`false` by default). Can be overridden in resource_pools. Example: `false`.
* **tags** (Array&lt;String&gt;, optional) - A list of [tags](https://cloud.google.com/compute/docs/instances/managing-instances#tags) to apply to the instances, useful if you want to apply firewall or routes rules based on tags. Will be merged with tags in resource_pools. Example: `["foo","bar"]`.

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
## VM Types / VM Extensions {: #vm-types }

Schema for `cloud_properties` section:

* **machine\_type** (String, required) - The name of the [Google Compute Engine Machine Type](https://cloud.google.com/compute/docs/machine-types) the CPI will use when creating the instance (required if not using `cpu` and `ram`). Example: `n1-standard-1`.
* **cpu** (Integer, required) - Number of vCPUs ([Google Compute Engine Custom Machine Types](https://cloud.google.com/custom-machine-types/)) the CPI will use when creating the instance (required if not using `machine_type`). Example: `2`.
* **ram** (Integer, required) - Amount of memory ([Google Compute Engine Custom Machine Types](https://cloud.google.com/custom-machine-types/)) the CPI will use when creating the instance (required if not using `machine_type`). Example: `2048`.
* **zone** (String, optional) - The name of the [Google Compute Engine Zone](https://cloud.google.com/compute/docs/zones) where the instance must be created. Example: `us-west1-a`.
* **root\_disk\_size\_gb** (Integer, optional) - The size (in Gb) of the instance root disk (default is `10Gb`). Example: `10`.
* **root\_disk\_type** (String, optional) - The name of the [Google Compute Engine Disk Type](https://cloud.google.com/compute/docs/disks/#overview) the CPI will use when creating the instance root disk. Example: `pd-standard`.
* **automatic\_restart** (Boolean, optional) - If the instances should be [restarted automatically](https://cloud.google.com/compute/docs/instances/setting-instance-scheduling-options#autorestart) if they are terminated for non-user-initiated reasons (`false` by default). Example: `false`.
* **on\_host\_maintenance** (String, optional) - [Instance behavior](https://cloud.google.com/compute/docs/instances/setting-instance-scheduling-options#onhostmaintenance) on infrastructure maintenance that may temporarily impact instance performance (supported values are `MIGRATE` (default) or `TERMINATE`). Example: `MIGRATE`.
* **preemptible** (Boolean, optional) - If the instances should be [preemptible](https://cloud.google.com/preemptible-vms/) (`false` by default). Example: `false`.
* **service\_account** (String, optional) - The full service account address of the service account to launch the VM with. If a value is provided, `service_scopes` will default to `https://www.googleapis.com/auth/cloud-platform` unless it is explicitly set. See [service account permissions](https://cloud.google.com/compute/docs/access/service-accounts#service_account_permissions) for more details. To use the default service account, leave this field empty and specify `service_scopes`. Example: `service-account-name@project-name.iam.gserviceaccount.com`.
* **service\_scopes** (Array&lt;String&gt;, optional) - If this value is specified and `service_account` is empty, `default` will be used for `service_account`. This value supports both short (e.g., `cloud-platform`) and fully-qualified (e.g., `https://www.googleapis.com/auth/cloud-platform` formats. See [Authorization scope names](https://cloud.google.com/docs/authentication#oauth_scopes) for more details. Example: `cloud-platform`.
* **target\_pool** (String, optional) - The name of the [Google Compute Engine Target Pool](https://cloud.google.com/compute/docs/load-balancing/network/target-pools) the instances should be added to. Example: `cf-router`.
* **backend\_service** (String OR Map&lt;String,String&gt;, optional) - The name of the [Google Compute Engine Backend Service](https://cloud.google.com/compute/docs/load-balancing/http/backend-service) the instances should be added to. The backend service must already be configured with an [Instance Group](https://cloud.google.com/compute/docs/instance-groups/#unmanaged_instance_groups) in the same zone as this instance. To set up [Internal Load Balancing](https://cloud.google.com/compute/docs/load-balancing/internal/) use a map and set `scheme` to `INTERNAL` and `name` to the name of the backend service. Example: `cf-router` (external), `{name: "cf-internal", scheme: "INTERNAL"} (internal)`.
* **ephemeral\_external\_ip** (Boolean, optional) - Overrides the equivalent option in the networks section. Example: `false`.
* **ip\_forwarding** (Boolean, optional) - Overrides the equivalent option in the networks section. Example: `false`.
* **tags** (Array&lt;String&gt;, optional) - Merged with tags from the networks section. Example: `["foo","bar"]`.
* **labels** (Map&lt;String,String&gt;, optional) - A dictionary of (key,value) labels applied to the VM. Example: `{"foo":"bar"}`.

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

Example of an `INTERNAL` backend service:

```yaml
vm_extensions:
- name: backend-pool
  cloud_properties:
    ephemeral_external_ip: true
    backend_service:
      name: name-of-backend-service
      scheme: INTERNAL
```

Example of an `EXTERNAL` backend service:

```yaml
vm_extensions:
- name: backend-pool
  cloud_properties:
    backend_service:
      name: name-of-backend-service
```
The above backend-service cloud configuration examples are referenced within the deployment manifest as such:

```yaml
instance_groups:
- name: proxy
  instances: 2
  azs: [z1, z2]
  networks: [{name: default}]
  vm_type: default
  stemcell: default
  jobs:
  - name: proxy
    release: default
  vm_extensions: [backend-pool]
```

---
## Disk Types {: #disk-types }

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
## Global Configuration {: #global }

The CPI can only talk to a single Google Compute Engine region.

See [all configuration options](https://bosh.io/jobs/google_cpi?source=github.com/cloudfoundry-incubator/bosh-google-cpi-release).

---
## Example Cloud Config {: #cloud-config }

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
