---
title: Runtime Config
---

<p class="note">Note: This feature is available with bosh-release v255.4+.</p>

The Director has a way to specify global configuration for all VMs in all deployments. The runtime config is a YAML file that defines IaaS agnostic configuration that applies to all deployments.

---
## <a id='update'></a> Updating and retrieving runtime config

To update runtime config on the Director use [`bosh update runtime-config`](sysadmin-commands.html#cloud-config) CLI command.

<p class="note">Note: See <a href="#example">example runtime config</a> below.</p>

<pre class="terminal">
$ bosh update runtime-config runtime.yml

$ bosh runtime-config
Acting as user 'admin' on 'micro'

releases:
- name: strongswan
  version: 6.0.0

addons:
- name: security
  jobs:
  - name: strongswan
    release: strongswan
...
</pre>

Once runtime config is updated all deployments will be considered outdated. `bosh deployments` does not currently show that but we have plans to show that information. The Director will apply runtime config changes to each deployment during the next `bosh deploy` for that deployment.

---
## <a id='example'></a> Example

```yaml
releases:
- name: strongswan
  version: 6.0.0

addons:
- name: security
  jobs:
  - name: strongswan
    release: strongswan
    properties:
      strongswan:
        ca_cert: ...
```

<p class="note">Note: To remove all addons, specify empty arrays as follows:</p>

```yaml
releases: []
addons: []
```

---
## <a id='releases'></a> Releases Block

**releases** [Array, required]: Specifies the releases used by the addons.

* **name** [String, required]: Name of a release name used by an addon.
* **version** [String, required]: The version of the release to use. Version *cannot* be `latest`; it must be specified explicitly.

Example:

```yaml
releases:
- name: strongswan
  version: 6.0.0
```

---
## <a id='addons'></a> Addons Block

Operators typically want to ensure that certain software runs on all VMs managed by the Director. Examples of such software are:

- security agents like Tripwire, IPsec, etc.
- anti-viruses like McAfee
- custom health monitoring agents like Datadog
- logging agents like Loggregator's Metron

An addon is a release job that is colocated on all VMs managed by the Director.

**addons** [Array, optional]: Specifies the [addons](./terminology.html#addon) to be applied to all deployments.

* **name** [String, required]: A unique name used to identify and reference the addon.
* **jobs** [Array of hashes, requires]: Specifies the name and release of release jobs to be colocated.
  * **name** [String, required]: The job name.
  * **release** [String, required]: The release where the job exists.
  * **properties** [Hash, optional]: Specifies job properties. Properties allow the Director to configure jobs to a specific environment.
* **include** [Hash, optional]: Specifies inclusion <a href="#placement-rules">placement rules</a> Available in bosh-release v260+.
* **exclude** [Hash, optional]: Specifies exclusion <a href="#placement-rules">placement rules</a>. Available in bosh-release v260+.

### <a id='placement-rules'></a> Placement Rules for `include` and `exclude` Directives

Available rules:

* **stemcell** [Array of hashes, optional]
  * **os** [String, required]: Matches stemcell's operating system. Example: `ubuntu-trusty`
* **deployments** [Array of strings, optional]: Matches based on deployment names.
* **jobs** [Array of hashes, otional]
  * **name** [String, required]: Matching job name.
  * **release** [String, required]: Matching release name.
* **networks** [Array of strings, optional]: Matches based on network names. Available in bosh-release v262+.

All arrays within inclusion/exclusion rules use `or` operator.

Example:

```yaml
addons:
- name: security
  jobs:
  - name: strongswan
    release: strongswan
    properties:
      strongswan:
        ca_cert: ...
  - name: syslog_drain
    release: syslog
    properties:
      syslog_drain_ips: [10.10.0.20]
  include:
    deployments: [dep1, dep2]
```

Example with `include` rules:

```yaml
include:
  deployments: [dep1, dep2]
  jobs:
  - name: redis
    release: redis-release
  stemcell:
  - os: ubuntu-trusty
```

See [common addons list](addons-common.html) for several examples.

---
## <a id='tags'></a> Tags Block

**tags** [Hash, optional]: Specifies key value pairs to be sent to the CPI for VM tagging. Combined with deployment level tags during the deploy. Available in bosh-release v260+.

Example:

```yaml
tags:
  business_unit: marketing
  email_contact: ops@marketing.co.com
```
