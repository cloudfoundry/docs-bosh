Using DNS within deployments:

- allows easy use of dynamic networks since IPs change with every redeploy
- provides a way to reference deployed VMs more transparently
- provides client side load balancing
- reduces number of configuration changes that need to be propagated when changing cluster layout

See [links](links.md) for more context in how to use links with BOSH.

---
## Architecture {: #arch }

To provide native DNS support:

- Director keeps track of DNS entries assigned to each instance
- Agent (on stemcells ubuntu-trusty/3421+, all ubuntu-xenial) updates DNS records metadata on its VM
- DNS release (more details below) provides resolution of BOSH specific DNS records

Given that the Director is the sole orchestrator of the system, it is now responsible for updating DNS records during a deploy. As VMs are created and deleted following DNS related steps happen:

1. Director notices that VM, after it's created or deleted, changed its IP
1. Director creates a new DNS records dataset and saves it to the blobstore
1. Director issues sync_dns Agent call to *all* VMs (in all deployments)
1. Each Agent downloads new DNS records dataset and updates `/var/vcap/instance/dns/records.json`
1. DNS release sees that local `/var/vcap/instance/dns/records.json` is updated, hence returns new information in future DNS requests

See [Deploying step-by-step](deploying-step-by-step.md) for full Director deployment flow.

---
## Types of DNS addresses {: #dns-addresses }

There are two types of DNS addresses that native DNS supports:

- instance specific queries that resolve to a single instance
  - provided by `spec.address` or `link("...").instances[...].address` ERB accessors
- group specific queries that resolve to multiple instances
  - provided by `link("...").address` ERB accessor

Since BOSH DNS is automatically managed, DNS addresses are not meant to be constructed manually by operators or scripts. To obtain a DNS address you can use Links API or job template accessors within your jobs.

---
## DNS release {: #dns-release }

To take advantage of native DNS functionality, it's expected that [DNS release](https://bosh.io/releases/github.com/cloudfoundry/bosh-dns-release?all=1) runs on each VM. We recommend to colocate DNS release by defining it in an [addon](runtime-config.md#addons).

DNS release provides two jobs: `bosh-dns` (for Linux) and `bosh-dns-windows` (for Windows) which start a simple DNS server bound to a [link local address](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p=address).

### Recursors {: #recursors }

Here is how DNS release chooses recursors before starting its operation:

1. by default will pick up recursors specified in `/etc/resolv.conf` (denoted by `nameserver` keyword)
  - alternatively, if `recursors` property is set use specified recursors
1. exclude recursors specified in `excluded_recursors` property
1. pick a recursor from the list of recursors
1. if you have a version of the DNS release after and including 1.12, the selection of recursors is based on `recursor_selection` strategy:
  - if `recursor_selection` is "smart":
    - note that all recursors in this list will be considered equivalent, i.e. able to resolve same domains
  - if `recursor_selection` is "serial":
    - the next recursor (in order) from the list of recursors is chosen
1. if you have a version before 1.12, then the behaviour is the same as having `recursor_selection` set to "smart" from above
1. failover to using another recursor, if current recursor fails
  - if you have a version before 1.18 connectivity problems do not account for resolution problems (NXDOMAIN, or other DNS level errors)

#### More on recursor_selection

In DNS release 1.12, the `recursor_selection` property was added to allow operators to dictate how recursors are chosen. There are two strategies: `smart` and `serial`.

`smart` is the default strategy which picks recursors randomly when doing a failover (pre-1.12 behaviour).

`serial` is the strategy where recursors are picked in the order they are given (from `/etc/resolv.conf` or from the `recursors` property).

Example with `recursor_selection` set to "smart" (default):

```yml
  jobs:
  - name: bosh-dns
    properties:
      recursor_selection: smart
    release: bosh-dns
```

Example with `recursor_selection` set to "serial":

```yml
  jobs:
  - name: bosh-dns
    properties:
      recursor_selection: serial
    release: bosh-dns
```

### Aliases {: #aliases }

DNS release allows operators to specify custom names for BOSH generated DNS records to ease migration or work with legacy software that requires very specific DNS record formats (e.g. `master0`, `slave0`, `slave1`).

There are two ways to configure aliases:

0. Installing a `dns/aliases.json` file through your own release job. By default, `bosh-dns` will glob local `/var/vcap/jobs/*/dns/aliases.json` files for aliases.
0. Statically configuring the [`aliases` property](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p=aliases) of the `bosh-dns` job running the DNS server.

The alias configuration should be a hash, with keys representing the alias and array values representing the target hostnames. Target hostnames will be resolved and merged before sending the results back to the client.

There are two special characters which can be used (see below for example usages of them):

 * asterisk (`*`) - used in target hostnames to match subdomains
 * underscore (`_`) - represents a subdomain and can be used to match the subdomain in the target hostname (useful for queries needing to resolve instance IDs)

#### Example

Using the following aliases configuration:

```json
{ "sql-db.service.cf.internal": [
    "*.mysql-z1.default.cf.bosh",
    "*.mysql-z2.default.cf.bosh" ],
  "_.cell.service.cf.internal": [
    "_.diego-cell.default.cf.bosh",
    "_.windows-cell.default.cf.bosh" ] }
```

The following queries demonstrate the expected resolution behaviors:

 * `sql-db.service.cf.internal` will internally resolve to all VMs in the `mysql-z1` and `mysql-z2` instance groups.
 * `myuuid.cell.service.cf.internal` might internally resolve to `myuuid.windows-cell.default.cf.bosh`, assuming `windows-cell` has an instance with a UUID of `myuuid`.
 * `_.cell.service.cf.internal` (literal query) will not resolve since it is different than asterisk aliases.

!!! tip
    Aliases are very useful when [migrating from Consul](dns.md#migrate-consul).

### Healthiness

DNS release provides a way to reference all instances (or a subset of instances) in a link via single DNS record. Instances can be queried using their DNS addresses and optional filters to limit results (see [Constructing Queries](#constructing-queries) for more information). The notion of instance healthiness is directly tied to the state of processes running on a VM. DNS release will continuously poll for updated healthiness information (same information is visible via `bosh instances --ps` command) on all instances from groups that were resolved at least once.

To enable healthiness, use `health.enabled` property and specify necessary TLS certificates. Canonical DNS runtime config with healthiness enabled can be found here: https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml.

By default, a VM is considered healthy if the process manager reports all processes as healthy (e.g. `monit`). For specific jobs, release authors may install a script at `bin/dns/healthy` to provide more precise healthiness checks. The `healthy` script must exit `0` if the job is healthy, or any other exit code for unhealthy. These scripts are run at regular intervals (by default, 5s) in addition to checking the status from the process manager. If any processes are failing or any `healthy` script reports as unhealthy, the VM will be considered unhealthy.

#### Aliases to services

!!! note
    This feature is available with bosh-release v269+.

##### Using aliases

Jobs which provide services can be configured to be addressable via a static alias. A job that currently provides a link can be aliased directly by updating the manifest to add the alias in the `provides` configuration of the job. Here is an example:

```
instance_groups:
- name: instance-group0
  jobs:
  - name: instance-job0
    provides:
      my-link:
        aliases:
        - domain: 'my-custom-alias.example.com'
          health_filter: "healthy"
    release: my-release
    properties: {}
```

If the job as defined in the release does not currently provide a link, you can still define an alias to that job but first you must define a custom link provider in order to do so like this:

```
instance_groups:
- name: instance-group0
  jobs:
  - name: instance-job0
    provides:
      my_custom_link:
        aliases:
        - domain: 'my-custom-alias.example.com'
          health_filter: "healthy"
    custom_provider_definitions:
    - name: my_custom_link
      type: my_custom_link_type
    release: my-release
    properties: {}
```

##### Types of aliases

###### Basic alias

A basic alias is an _unparameterized_ alias on a _constant domain_ with a _constant_ query.  It returns all IPs matching the filter that provide that link.

Example:
```
aliases:
  - domain: my-service.my-domain
    health_filter: smart/healthy/unhealthy/all
    initial_health_check: asynchronous/synchronous
```

###### Wildcard alias
A wildcard alias is an _unparameterized_ alias on a _wildcard domain_ with a _constant_ query.
It returns all IPs matching the filter that provide that link.

Example:
```
aliases:
- domain: "*.cloud-controller-ng.service.cf.internal"
  health_filter: smart/healthy/unhealthy/all
  initial_health_check: asynchronous/synchronous
```

###### Placeholder alias
A placeholder alias is a _parameterizable_ alias on a _wildcard domain_ with a _variable_ query.
It returns IPs matching both the filter that provides that link and the placeholder replacement.

It allows referencing a placeholder (_) specified in the alias. The type of the placeholder can be configured, to allow referencing by instance uuid, index, availability_zone, or network.

Example:
```
aliases:
- domain: "_.cloud-controller-ng.service.cf.internal"
  placeholder_type: uuid/index/az/network
  health_filter: smart/healthy/unhealthy/all
  initial_health_check: asynchronous/synchronous
```

###### Parameters in Detail

**domain** [String] (*required*) 

Describes the domain name the alias should return results for when queried.

**placeholder_type** [String] (*situationally required*)

Only applicable if the domain contains the _ placeholder, and required in that case.
Determines whether the _ will stand in for a uuid, index, availability_zone, or network.

- `uuid`:  _ will be expected to be an instance-uuid

- `index`: _ will be expected to be an instance-index

- `availability_zone`: _ will be expected to be an availability zone name

- `network`: _ will be expected to be a network name

Examples:

- A query to `3.cloud-controller-ng.service.cf.internal` will return the IP for the 4th instance of cloud-controller-ng if `placeholder_type` is set to `index`.

- A query to `e23e4567-e89b-12d3-a456-426655440000.cloud-controller-ng.service.cf.internal` will return the IP for an instance of cloud-controller-ng with the uuid `e23e4567-e89b-12d3-a456-426655440000` if `placeholder_type` is set to `uuid`.

**health_filter** [String] (*optional*)

If present, filters the results to only return jobs matching the specified health status, e.g. only healthy ones, unhealthy ones, or all of them.

-  `smart` (default) returns only healthy or unchecked jobs; however, if all the jobs in an instance_group are unhealthy all of them are returned.

-  `healthy` returns only healthy jobs

-  `unhealthy` returns only unhealthy

-  `all` returns all jobs regardless of their health


**initial_health_check** [String] (*optional*)

Because BOSH has to start tracking a given job's health status, by default it will return all (unfiltered) IPs on the very first request and asynchronously begin tracking their health. 
Setting this to `synchronous` will force BOSH to wait for the first health statuses to come in and filter by them. This will take longer, but guarantees that health has been checked at least once even for the very first DNS request. 

- `asynchronous` (default) will return unchecked results to smart queries and begin health-checking those IP addresses in the background

- `synchronous` forces BOSH to check job health on the very first request before returning any results

###### Grouping link providers under an alias

It is possible for more than one link provider to define domains with the exact same values.  If this happens, the queries will each be run independently and the results will be merged.

For example, with the following deployment manifest:
deployment.yml:
```
instance_groups:
# ...
- name: proxied
  jobs:
  - name: nginx
    provides:
      conn:
        aliases:        
        - domain: "api.bosh.internal"
# ...
- name: direct
  jobs:
  - name: web
    provides:
      auctioneer:
        aliases:
        - domain: "api.bosh.internal"
          health_filter: all
          initial_health_check: synchronous
```

Both proxied and direct define api.bosh.internal as an alias, but with different filters. Resolving the api.bosh.internal address would return both:
1. IPs of VMs for the proxied instance group in which the nginx job is healthy or unchecked
1. IPs of VMs for the direct instance group in which the web job is healthy (checking the health synchronously on the first request)

### Caching

DNS release provides a way to enable response caching based on response TTLs. Enabling caching typically will alleviate some pressure from your upstream DNS servers and decrease latency of DNS resolutions.

To enable caching, use `cache.enabled` property. Canonical DNS runtime config with caching enabled can be found here: https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml.

### Additional Handlers

DNS release provides a way to delegate certain domains via [`handlers` property](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p=handlers) to different DNS or HTTP servers. This functionality can be used as an alternative to configuring upstream DNS servers with custom zone configurations.

---
## Enabling DNS {: #enable }

To enable native BOSH functionality, you must first enable [`local_dns.enabled` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.enabled) in the Director job. See [bosh-deployment's bosh.yml](https://github.com/cloudfoundry/bosh-deployment/blob/90bac489919fd4512bc9bb4d24070d71b07cd586/bosh.yml#L92-L93) as an example.

Enabling `local_dns.enabled` configuration will make Director broadcast DNS updates to all VMs. Only VMs based on 3421+ Linux stemcells will accept DNS broadcast message.

If you were relying on instance index based DNS records, you must enable [`local_dns.include_index` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.enabled) in the Director job.

Additionally you should colocate DNS release via an addon in all your deployments. See [bosh-deployment's runtime-configs/dns.yml](https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml) as an example.

---
## Disabling DNS {: #disable }
To disable the native BOSH functionality, you must disable the [`local_dns.enabled` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.enabled) in the Director job and remove the addon for the DNS release.

**Note:** Because of a known issue in [the `bosh-dnsrelease`](https://github.com/cloudfoundry/bosh-dns-release/issues/34) you have to recreate all VMs afterwards, in order to remove the local DNS server from `/etc/resolv.conf`.

---
## DNS Monitoring {: #monitoring }
DNS release provides monitoring, which can be enabled with [`metrics.enabled` property](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p%3dmetrics.enabled) or with this [addon config](https://github.com/cloudfoundry/bosh-deployment/blob/master/misc/dns-addon-enable-local-monitoring.yml). By default the metrics endpoint will be exposed on `http://127.0.0.1:53088/metrics`. The bind address for the metrics server could be change with [`metrics.address` property](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p%3dmetrics.address) and the port with [`metrics.port` property](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p%3dmetrics.port) or with this [addon config](https://github.com/cloudfoundry/bosh-deployment/blob/master/misc/dns-addon-enable-external-monitoring.yml).

---
## Impact on links {: #links }

Each link includes some networking information about its provider. Addresses returned by a link may be either IP addresses or DNS addresses.

As of bosh-release v263 opting into DNS addresses in links must be done explicitly. Previous Director versions would opt into this behaviour by default.

You can control type of addresses returned at three different levels:

- for the entire Director via Director job configuration [`director.local_dns.use_dns_addresses` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.use_dns_addresses) that if enabled affects all deployments by default. We are planning to eventually change this configuration to true by default.

- for a specific deployment via [`features.use_dns_addresses` deployment manifest property](manifest-v2.md#features) that if enabled affects links within this deployment

- for a specific link via its `ip_addresses` configuration

    If for some reason (discouraged) particular job cannot work with links that return DNS addresses, you can ask the Director to return IP addresses on best effort basis. Here is an example how to opt into this behaviour for a single link:

    ```yaml
    instance_groups:
    - name: zookeeper
      jobs:
      - name: zookeeper
        release: zookeeper
        consumes:
          peers: {ip_addresses: true}
    ...
    ```

Once native DNS addresses in links are enabled DNS addresses will be returned instead of IPs. Note that links provided by instance groups placed on dynamic networks will always provide DNS addresses.

```ruby
# before
link("db").address => "q-s0.db.default.db.bosh"
link("db").instances[0].address => "172.10.10.0"

# after
link("db").address => "q-s0.db.default.db.bosh"
link("db").instances[0].address => "ef489dd9-48f6-45f0-b7af-7f3437919b17.db.default.db.bosh"
```

---
## Impact on job's address (`spec.address`) {: #job-address }

Similar to how [links are affected](dns.md#links), `spec.address` will start returning DNS address once `use_dns_addresses` feature is enabled.

---
## Migrating from PowerDNS {: #migrate-powerdns }

Historically BOSH users did not have an easy highly available solution to enable DNS for their deployments. PowerDNS was a possible choice; however, it required more advanced configuration that we felt comfortable recommending to everyone. We are planning to deprecate and remove PowerDNS integration. To migrate from PowerDNS to native DNS:

1. continue deploying Director with `powerdns` job
1. enable native DNS (follow [Enabling DNS](dns.md#enable) section above) with proper recursors configured
1. redeploy all deployments and make sure that native DNS is in use
1. redeploy Director without `powerdns` job

---
## Migrating from Consul {: #migrate-consul }

To ease migration from Consul DNS entries, DNS release provides [aliases feature](dns.md#aliases). It allows operators to define custom DNS entries that can map to BOSH generated DNS entries. To migrate off of Consul to native DNS:

1. enable native DNS (follow [Enabling DNS](dns.md#enable) section above) with proper recursors configured
1. continue deploying `consul_agent` job
1. define native DNS aliases that match existing Consul DNS entries
1. redeploy all deployments that use Consul
1. redeploy all deployments without `consul_agent` job

---
## Constructing DNS Queries {: #constructing-queries }

BOSH DNS provides its own structured query language for querying instances
based on an instance's endemic and organizational relationship; e.g., by an
instance's healthiness, its availability zone, or group id.

A few example DNS queries:

* `dig @bosh-dns q-s3.zookeeper.*.zk-prod.bosh`

Query for BOSH instances that are healthy (`q-s3`), from instance group `zookeeper`, on all networks (`*`), in deployment `zk-prod`.

* `dig @bosh-dns q-s1-a2.diego-cell.*.*.bosh`

Query for BOSH instances that are unhealthy (`q-s1`), that are in availability zone 2 (`q-a2`), from instance group `diego_cell`, on any network (`*`) and any deployment (`*`). **Note:** BOSH DNS converts instance groups with underscores in their name to hyphens (e.g. `diego_cell` becomes `diego-cell`).

* `dig @bosh-dns q-s4.*.bosh`

Query for all BOSH instances regardless of healthiness (`q-s4`). This effectively returns all instances across all deployments on the BOSH director.

More generally:

```shell
dig @bosh-dns q-a*i*m*n*s*y*.q-g*.your-domain.bosh.
```

Query parameters are:

* `a*` = availability zone
  * where `*` is the numerical id of the availability zone
* `i*` = instance id
* `m*` = numerical uuid
* `n*` = network
  * where `*` is the numerical id of the network
* `s*` = healthiness
  * The following options are available:
    * `s0` - _Default_ - 'smart' strategy that returns healthy and unchecked instances; if
      there are no healthy or unchecked instances, all instances will be returned
    * `s1` - returns only unhealthy instances
    * `s3` - return only healthy instances
    * `s4` - return all instances
* `y*` = synchronous healthcheck
  * The following options are available:
    * `y0` - _Default_ - do not attempt to get healthiness on the first query
    * `y1` - Perform a synchronous health check the first time the record is
      resolved. This is useful for applications that are not designed to continuosly
      re-resolve and therefore need to receive a healthy instance on the first
      record resolution.
* `g*` = group (internal)
  * where `*` is the global instance group id
  * this flag is used almost exclusively for debugging purposes only

---
## Consuming BOSH DNS in Job Templates {: #consuming-dns-job-templates }

BOSH DNS' query language is not meant to be manually crafted. As a release
author, one should use links for generating those queries in their job
templates.

An example of how to build a link-based query is:

```erb
<%=
  link('db').address(
    azs: ['az1'],
    status: 'healthy',
  )
%>
```

Will result in: `q-a1s3.q-g5.your-domain.bosh.` assuming `az1` is of id `1` and
the `db` group is of id `5`.

The following options are available when constructing a link query:

 * `azs` (`a*`): list of availability zone names
 * `uuid` (`m*`): instance uuid
 * `status` (`s*`): health status. Can be one of `default`, `healthy`, `unhealthy`, or `all`
 * `default_network` (`n*`): network name
 * `instance_group` (`g*`): instance group name
 * `deployment_name` (`g*`): deployment name

---
## BOSH DNS Addresses in Config Server Generated Certs {: #dns-variables-integration}

!!! note
    This feature is still in alpha phase.

With BOSH `v267+`, [Config Server](variable-types.md) generated certificates can be optionally created with automatic BOSH DNS records in their Common Name and/or Subject Alternative Names. 

A [variable](variable-types.md) of type `certificate` can now **explicitly** consume two links:

1. **Name:** `alternative_name`, **Type:** `address`. When consumed, the BOSH DNS address of the link provider will be added to the Subject Alternative Names of the generated certificate.
1. **Name:** `common_name`, **Type:** `address`. When consumed, the BOSH DNS address of the link provider will be set as the Common Name of the generated certificate **ONLY IF** the variable definition does not specify a common name. If the variable definition specifies a common name, it will **NOT** be overridden. 

**Note that the above 2 links are optional.**

The recommended way to hook the links providers with the consumers variables is by using the [custom provider definition](links.md#custom-provider-definitions) feature.

### Consuming `alternative_name`

In the example below, the variable of type certificate `app_server_cert` is explicitly consuming `alternative_name` from the `my-custom-app-server-address` provider. This will lead to the `app_server_cert` certificate being generated with an additional SAN: the BOSH DNS address of the instance group `server_ig` where the link provider (the job `app_server`) exists. For example: `q-s0.server_ig.default.app-service.bosh`.

```
name: app-service

  ...

instance_groups:
- name: server_ig
  jobs:
   - name: app_server
     provides:
       app-server-address:
         as: my-custom-app-server-address
     custom_provider_definitions:
     - name: app-server-address  
       type: address
  ...

variables:
- name: default_ca
  type: certificate
  options:
    is_ca: true
    common_name: Default CA
- name: app_server_cert
  type: certificate
  options:
    ca: default_ca
    common_name: My Application Server
  consumes:
    alternative_name: { from: my-custom-app-server-address }
```

### Consuming `common_name`

It is also possible to set the common name to the appropriate BOSH DNS record.

In the example below, the variable of type certificate `app_server_cert` is explicitly consuming `common_name` from the `my-custom-app-server-address` provider. This will set the Common Name of `app_server_cert` generated certificate to be the BOSH DNS address of the instance group `server_ig` where the link provider (the job `app_server`) exists. For example, the common name will be set to `q-s0.server_ig.default.app-service.bosh`.

```
variables:
  - name: app_server_cert
    type: certificate
    options:
      ca: default_ca
    consumes:
      common_name: { from: my-custom-app-server-address }
```

### Allowing for wildcards

If the application talks to specific instances or uses different healthiness filtering, it may be useful to request a wildcard DNS name when consuming a link for either SANs or common name:

```
variables:
  - name: app_server_cert
    type: certificate
    options:
      ca: default_ca
      common_name: Application Server
    consumes:
      alternative_name:
        from: my-custom-app-server-address
        properties: { wildcard: true }
```

Which will result in the variable called `app_server_cert` having a SAN set to

* DNS: `*.server_ig.default.app-service.bosh`.

### When Variable Definition has SANS and/or CN Defined in its Options

If the variable of type certificate defines a list of Subject alternative Names in its options, and at the same time it consumes the `alternative_name` link, the BOSH DNS address of the provider will be added to the list SANs in the generated certificate. 

In contrast, if the variable of type certificate defines a Common Name in its options, and at the same time it consumes the `common_name` link, the BOSH DNS address of the provider will **NOT** override the Common Name defined in options. 

For example, the `app_server_cert` cert below will have "**Application Server**" as Common Name, and will have the following SANs:
             
 * DNS: `custom-record.appservers.cf.local`
 * DNS: `*.serverig.default.app-service.bosh`
 * IP: 172.158.20.255

```
variables:
  - name: app_server_cert
    type: certificate
    options:
      ca: default_ca
      common_name: "Application Server"
      alternative_names: [ "custom-record.appservers.cf.local", 172.158.20.255 ]
    consumes:
      alternative_name:
        from: my-custom-app-server-address
        properties: { wildcard: true }
      common_name: { from: my-custom-app-server-address }
```

!!! Warning
    In order for the variables to be regenerated by Config Server(usually Credhub) when any of their options changes, the [`update_mode`](manifest-v2.md#variables) option should be set to `converge` in the deployment manifest.
 
---
## Rotating BOSH DNS Certificates {: #rotating-dns-certificates }

BOSH DNS Health Monitor Certificates should be performed in three steps in order to achieve zero downtime.

Given you used bosh-deployment to update your runtime config as in:
```
bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --vars-store bosh-dns-certs.yml
```

1. Step 1 (Add new CA Certificates to runtime config):

  This will make sure the new certificates (step 2) will be properly validated against new CA Certificate,
  and old certificates will be validated against the previous one.

  ```
  cat > rotate-dns-certs-1.yml <<EOF
  ---
  - type: replace
    path: /variables/-
    value:
      name: /dns_healthcheck_tls_ca_new
      type: certificate
      options:
        is_ca: true
        common_name: dns-healthcheck-tls-ca

  - type: replace
    path: /variables/-
    value:
      name: /dns_healthcheck_server_tls_new
      type: certificate
      options:
        ca: /dns_healthcheck_tls_ca_new
        common_name: health.bosh-dns
        extended_key_usage:
        - server_auth

  - type: replace
    path: /variables/-
    value:
      name: /dns_healthcheck_client_tls_new
      type: certificate
      options:
        ca: /dns_healthcheck_tls_ca_new
        common_name: health.bosh-dns
        extended_key_usage:
        - client_auth

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/server/tls?
    value:
      ca: ((/dns_healthcheck_server_tls.ca))
      certificate: ((/dns_healthcheck_server_tls.certificate))
      private_key: ((/dns_healthcheck_server_tls.private_key))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/client/tls?
    value:
      ca: ((/dns_healthcheck_client_tls.ca))
      certificate: ((/dns_healthcheck_client_tls.certificate))
      private_key: ((/dns_healthcheck_client_tls.private_key))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/server/tls/ca
    value: ((/dns_healthcheck_server_tls.ca))((/dns_healthcheck_server_tls_new.ca))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/client/tls/ca
    value: ((/dns_healthcheck_client_tls.ca))((/dns_healthcheck_client_tls_new.ca))
  EOF

  bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --vars-store bosh-dns-certs.yml \
    -o rotate-dns-certs-1.yml
  ```
  Redeploy all VMs.

1. Step 2 (Add new Certificates to runtime config):

  At this step the VMs with new certificates will be able to properly start up since they match the new CA Certificate,
  as well as the old ones. By the end of this step you will all VMs running with new certificates, however the previous
  CA Certificates are still configured and should be removed for security reasons.

  ```
  cat > rotate-dns-certs-2.yml <<EOF
  ---
  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/server/tls/certificate
    value: ((/dns_healthcheck_server_tls_new.certificate))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/server/tls/private_key
    value: ((/dns_healthcheck_server_tls_new.private_key))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/client/tls/certificate
    value: ((/dns_healthcheck_client_tls_new.certificate))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/client/tls/private_key
    value: ((/dns_healthcheck_client_tls_new.private_key))
  EOF

  bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --vars-store bosh-dns-certs.yml \
    -o rotate-dns-certs-1.yml -o rotate-dns-certs-2.yml
  ```
  Redeploy all VMs.

1. Step 3 (Remove old Certificates from runtime config):

  Finally this step should remove the old certificates from all you deployments.

  ```
  cat rotate-dns-certs-3.yml <<EOF
  ---
  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/server/tls/ca
    value: ((/dns_healthcheck_server_tls_new.ca))

  - type: replace
    path: /addons/0/jobs/name=bosh-dns/properties/health/client/tls/ca
    value: ((/dns_healthcheck_client_tls_new.ca))
  EOF

  bosh update-runtime-config bosh-deployment/runtime-configs/dns.yml --vars-store bosh-dns-certs.yml \
    -o rotate-dns-certs-1.yml -o rotate-dns-certs-2.yml -o rotate-dns-certs-3.yml
  ```
  Redeploy all VMs.

--
## Instance `records.json` Data

Each VM receives a local copy of the latest DNS data (via the BOSH agent on the VM) whenever VMs are added or removed from the system. This data file is installed to `/var/vcap/instance/dns/records.json`. Below is an example of the schema...

```json
{
  "record_keys": [
    "id",
    "num_id",
    "instance_group",
    "group_ids",
    "az",
    "az_id",
    "network",
    "network_id",
    "deployment",
    "ip",
    "domain",
    "agent_id",
    "instance_index"
  ],
  "record_infos": [
    [
      "4d516417-e1e5-4aa5-a038-91e369716821",
      "12345",
      "my-instance-group-name",
      [
        "2345"
      ],
      "my-az-name",
      "34",
      "my-network-name",
      "45",
      "my-deployment-name",
      "192.0.2.101",
      "bosh",
      "6615c4f0-9a52-4ba0-b15c-6534b9bd99a9"
    ],
    ...
  ]
}
```

!!! warning
    This is an internal API with the BOSH management plane. Depending on director versions being used in an environment, some keys may be missing and additional keys may be present. You should not use this information directly - use DNS queries against the BOSH DNS server to find VM details.
