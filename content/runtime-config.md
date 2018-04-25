---
title: Runtime Config
---

!!! note
    This feature is available with bosh-release v255.4+.

The Director has a way to specify global configuration for all VMs in all deployments. The runtime config is a YAML file that defines IaaS agnostic configuration that applies to all deployments.

---
## Updating and retrieving runtime config {: #update }

To update runtime config on the Director use [`bosh update runtime-config`](sysadmin-commands.md#cloud-config) CLI command.

!!! note
    See [example runtime config](#example) below.

```shell
$ bosh update-runtime-config runtime.yml

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
```

Once runtime config is updated all deployments will be considered outdated. `bosh deployments` does not currently show that but we have plans to show that information. The Director will apply runtime config changes to each deployment during the next `bosh deploy` for that deployment.

---
## Example {: #example }

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

!!! note
    To remove all addons, specify empty arrays as follows:

```yaml
releases: []
addons: []
```

---
## Releases Block {: #releases }

**releases** [Array, required]: Specifies the releases used by the addons.

* **name** [String, required]: Name of a release name used by an addon.
* **version** [String, required]: The version of the release to use. Version *cannot* be `latest`; it must be specified explicitly.
* **url** [String, optional]: URL of a release to download. Works with CLI v2. Example: `https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=11`.
* **sha1** [String, optional]: SHA1 of asset referenced via URL. Works with CLI v2. Example: `332ac15609b220a3fdf5efad0e0aa069d8235788`.

See [Release URLs](release-urls.md) for more details.

Example:

```yaml
releases:
- name: strongswan
  version: 6.0.0
```

Example with a URL:

```yaml
releases:
- name: concourse
  version: 3.3.2
  url: https://bosh.io/d/github.com/concourse/concourse?v=3.3.2
  sha1: 2c876303dc6866afb845e728eab58abae8ff3be2
```

---
## Addons Block {: #addons }

Operators typically want to ensure that certain software runs on all VMs managed by the Director. Examples of such software are:

- security agents like Tripwire, IPsec, etc.
- anti-viruses like McAfee
- custom health monitoring agents like Datadog
- logging agents like Loggregator's Metron

An addon is a release job that is colocated on all VMs managed by the Director.

**addons** [Array, optional]: Specifies the [addons](terminology.md#addon) to be applied to all deployments.

* **name** [String, required]: A unique name used to identify and reference the addon.
* **jobs** [Array of hashes, requires]: Specifies the name and release of release jobs to be colocated.
    * **name** [String, required]: The job name.
    * **release** [String, required]: The release where the job exists.
    * **properties** [Hash, optional]: Specifies job properties. Properties allow the Director to configure jobs to a specific environment.
* **include** [Hash, optional]: Specifies inclusion [placement rules](#placement-rules) Available in bosh-release v260+.
* **exclude** [Hash, optional]: Specifies exclusion [placement rules](#placement-rules). Available in bosh-release v260+.

### Placement Rules for `include` and `exclude` Directives {: #placement-rules }

Available rules:

* **stemcell** [Array of hashes, optional]
    * **os** [String, required]: Matches stemcell's operating system. Example: `ubuntu-trusty`
* **deployments** [Array of strings, optional]: Matches based on deployment names.
* **jobs** [Array of hashes, optional]
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

See [common addons list](addons-common.md) for several examples.

---
## Tags Block {: #tags }

**tags** [Hash, optional]: Specifies key value pairs to be sent to the CPI for VM tagging. Combined with deployment level tags during the deploy. Available in bosh-release v260+.

Example:

```yaml
tags:
  business_unit: marketing
  email_contact: ops@marketing.co.com
```
