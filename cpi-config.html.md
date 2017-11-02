---
title: CPI Config
---

<p class="note">Note: This feature is available with bosh-release v261+.</p>

In most cases having single Director use a single CPI and hence a single IaaS section (for example one AWS account, vSphere datacenter, or OpenStack tenant) is enough. But in some cases operator may want to rely on multiple IaaS sections to achieve necessary isolation, availability, capacity, scalability, security, and/or management needs. To address such configuration scenarios  Director can be configured with multiple CPIs at runtime (instead of only allowing single CPI configuration at the deploy time).

The CPI config is a YAML file that defines multiple CPIs and properties necessary for each CPI to communicate with an appropriate IaaS section. Once CPIs are specified, operator can associate particular AZ in their cloud config to a particular CPI.

---
## <a id='update'></a> Updating and retrieving CPI config

To update CPI config on the Director use [`bosh update-cpi-config`](cli-v2.html#update-cpi-config) CLI command.

<p class="note">Note: See <a href="#example">example CPI config</a> below.</p>

<pre class="terminal">
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
</pre>

Once CPI config is updated AZs in the cloud config can reference specific CPI to be used during a deploy. Unlike runtime and cloud configs, CPI config is not tracked directly by the deployments and can be updated separately (useful for updating CPI credentials without forcing redeploy of all the deployments).

---
## <a id='example'></a> Example

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

AZs in cloud config can reference CPIs by their given names:

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

---
## <a id='cpis'></a> CPIs Block

**cpis** [Array, required]: Specifies the CPIs.

* **name** [String, required]: Unique name for a CPI. Example: `openstack-1a`.
* **type** [String, required]: CPI type. Director will add `_cpi` suffix to the end of the type when calling CPI binary. Example: `openstack`, `google`.
* **properties** [Hash, required]: Set of properties to provide to the CPI for each call so that CPI can authenticate and provision resources in an IaaS.

<p class="note">Note: Properties will vary depending on the CPI you're trying to use. These are the `Global Configuration` of a given CPI. See <a href="cpi-config.html#cpi-config">a complete list of the CPI properties</a>.</p>

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
