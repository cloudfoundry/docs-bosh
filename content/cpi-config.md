---
title: CPI Config
---

!!! note
    This feature is available with bosh-release v261+.

In most cases having single Director use a single CPI and hence a single IaaS section (for example one AWS account, vSphere datacenter, or OpenStack tenant) is enough. But in some cases operator may want to rely on multiple IaaS sections to achieve necessary isolation, availability, capacity, scalability, security, and/or management needs. To address such configuration scenarios  Director can be configured with multiple CPIs at runtime (instead of only allowing single CPI configuration at the deploy time).

The CPI config is a YAML file that defines multiple CPIs and properties necessary for each CPI to communicate with an appropriate IaaS section. Once CPIs are specified, operator can associate particular AZ in their cloud config to a particular CPI.

---
## Updating and retrieving CPI config {: #update }

To update CPI config on the Director use [`bosh update-cpi-config`](cli-v2.md#update-cpi-config) CLI command.

!!! note
    See <a href="#example">example CPI config</a> below.

```shell
$ bosh update-cpi-config cpis.yml

$ bosh cpi-config
Using environment '192.168.56.6' as client 'admin'

cpis:
- name: openstack-1a
  type: openstack
  properties:
    ...
- name: openstack-1b
  type: openstack
  properties:
    ...
```

Once CPI config is updated AZs in the cloud config can reference specific CPI to be used during a deploy. Unlike runtime and cloud configs, CPI config is not tracked directly by the deployments and can be updated separately (useful for updating CPI credentials without forcing redeploy of all the deployments).

---
## CPIs Block {: #cpis }

**cpis** [Array, required]: Specifies the CPIs.

* **name** [String, required]: Unique name for a CPI. Example: `openstack-1a`.
* **type** [String, required]: CPI type. Director will add `_cpi` suffix to the end of the type when calling CPI binary. Example: `openstack`, `google`.
* **properties** [Hash, required]: Set of properties to provide to the CPI for each call so that CPI can authenticate and provision resources in an IaaS.

!!! note
    Properties will vary depending on the CPI you're trying to use. These are the `Global Configuration` of a given CPI. See <a href="cpi-config.html#cpi-config">a complete list of the CPI properties</a>.

OpenStack example:

```yaml
cpis:
- name: openstack-1a
  type: openstack
  properties:
    auth_url: ((auth_url))
    username: ((openstack_username))
    api_key: ((openstack_password))
    domain: ((openstack_domain))
    project: ((openstack_project))
    region: ((region))
    default_key_name: ((default_key_name))
    default_security_groups: ((default_security_groups))
    human_readable_vm_names: true
```

vSphere example:

```yaml
cpis:
- name: ((vcenter_identifier))
  type: vsphere
  properties:
    host: ((vcenter_ip))
    user: ((vcenter_user))
    password: ((vcenter_password))
    datacenters:
    - clusters:
      - { ((vcenter_cluster)): {}}
      datastore_pattern: ((vcenter_datastores_pattern))
      disk_path: ((folder_to_put_disks_in))
      name: ((vcenter_datacenter))
      persistent_datastore_pattern: ((vcenter_persistent_datastores_pattern))
      template_folder: ((folder_to_put_templates_in))
      vm_folder: ((folder_to_put_vms_in))
```

For vSphere, if your datacenter and cluster names have spaces in them, there is no need to put quotes around them when updating your cpi-config.

---
## Example {: #example }

Example of a CPI config referencing two separate OpenStack installations:

```yaml
cpis:
- name: openstack-1a
  type: openstack
  properties:
    api_key: ...
    auth_url: ...
- name: openstack-1b
  type: openstack
  properties:
    api_key: ...
    auth_url: ...
```

AZs in cloud config can reference openstack CPIs by their given names:

```yaml
azs:
- name: z1
  cpi: openstack-1a
  cloud_properties:
    availability_zone: us-east-1a
- name: z2
  cpi: openstack-1b
  cloud_properties:
    availability_zone: us-east-1b
...
```

Example of a CPI config referencing two separate vSphere installations:

```yaml
cpis:
- name: vcenter-1a
  type: vsphere
  properties:
    host: vcenter-1a-ip
    user: vcenter-1a-user
    password: vcenter-1a-password
    datacenters:
    - clusters:
      - {vcenter-1a-cluster: {}}
      datastore_pattern: ^(lun01|lun02|lun03|lun04|lun05)$
      disk_path: vcenter-1a-disks/disks
      name: vcenter-1a-datacenter
      persistent_datastore_pattern: ^(lun01|lun02|lun03|lun04|lun05)$
      template_folder: vcenter-1a-disks/templates
      vm_folder: vcenter-1a-disks/vms
- name: vcenter-1b
  type: vsphere
  properties:
    host: vcenter-1b-ip
    user: vcenter-1b-user
    password: vcenter-1b-password
    datacenters:
    - clusters:
      - {vcenter-1b-cluster: {}}
      datastore_pattern: ^(lun01|lun02|lun03|lun04|lun05)$
      disk_path: vcenter-1b-disks/disks
      name: vcenter-1b-datacenter
      persistent_datastore_pattern: ^(lun01|lun02|lun03|lun04|lun05)$
      template_folder: vcenter-1b-disks/templates
      vm_folder: vcenter-1b-disks/vms
```

AZs in cloud config can reference vSphere CPIs by their given names:

```yaml
azs:
- name: z1
  cpi: vcenter-1a
- name: z2
  cpi: vcenter-1b
...
```

---
## CPI Specific Stemcells {: #stemcells }
Stemcells need to be assigned to a specific CPI and it occurs on upload. If you've already uploaded an appropriate stemcell you'll need to re-upload with `--fix`

```bash
bosh upload-stemcell .tgz --fix
```
