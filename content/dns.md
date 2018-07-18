!!! note
    This feature is still under development; however, there are portions of DNS functionality that are already available in bosh-release v262+. 3468+ Linux stemcells are required.

Using DNS instead of plain IPs within deployments:

- allows easy use of dynamic networks since IPs change with every redeploy
- provides a way to reference deployed VMs more transparently
- provides client side load balancing
- reduces number of configuration changes that need to be propagated when changing cluster layout

Historically BOSH users did not have an easy highly available solution to enable DNS for their deployments. PowerDNS was a possible choice; however, it required more advanced configuration that we did not feel comfortable recommending to everyone.

Addition of native BOSH DNS solves these problems without making it hard to deploy and operate DNS servers.

See [links](links.md) for more context in how to use links with BOSH.

---
## Architecture {: #arch }

To provide native DNS support following changes were made:

- Director keeps track of DNS entries assigned to each instance
- Agent (on stemcells 3421+) updates DNS records metadata on its VM
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

Since BOSH DNS is automatically managed, DNS addresses are not meant to be constructed manually by operators or scripts. To obtain a DNS address you can use upcoming Links API or job template accessors within your jobs.

---
## DNS release {: #dns-release }

To take advantage of native DNS functionality, it's expected that [DNS release](https://bosh.io/releases/github.com/cloudfoundry/bosh-dns-release?all=1) runs on each VM. We recommend to colocate DNS release by definiting it in an [addon](runtime-config.md#addons).

DNS release provides two jobs: `bosh-dns` (for Linux) and `bosh-dns-windows` (for Windows) which start a simple DNS server bound to a [link local address](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p=address).

### Recursors {: #recursors }

Here is how DNS release chooses recursors before starting its operation:

1. by default will pick up recursors specified in `/etc/resolv.conf` (denoted by `nameserver` keyword)
  - alternatively, if `recursors` property is set use specified recursors
1. exclude recursors specified in `excluded_recursors` property
1. randomly pick one recursor from the list of recursors
  - note that all recursors in this list will be considered equivalent, i.e. able to resolve same domains
1. failover to using another randomly picked recursor, if current recursor exhibits connectivity problems
  - connectivity problems do not account for resolution problems (NXDOMAIN, or other DNS level errors)

### Aliases {: #aliases }

DNS release allows operators to specify custom names for BOSH generated DNS records to ease migration or work with legacy software that requires very specific DNS record formats (e.g. `master0`, `slave0`, `slave1`).

There are two ways to specify aliases:

- via [`aliases` property](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/bosh-dns-release#p=aliases)
- via `dns/aliases.json` template inside your job

Example usage of `aliases` property:

```yaml
properties:
  aliases:
    bbs.service.cf.internal:
    - "*.database-z1.diego1.cf-cfapps-io2-diego.bosh"
    - "*.database-z2.diego2.cf-cfapps-io2-diego.bosh"
```

Above will resolve `bbs.service.cf.internal` to a all IPs (shuffled) matching following instance patterns: `*.database-z1.diego1.cf-cfapps-io2-diego.bosh` or `*.database-z2.diego2.cf-cfapps-io2-diego.bosh`.

See [Migrating from Consul](dns.md#migrate-consul) for more details.

### Healthiness

DNS release provides a way to reference all instances (or a subset of instances)
in a link via single DNS record. Instances can be queried using their DNS
addresses and a healthiness filter to filter healthy/unhealthy instances (see
[Constructing Queries](#constructing-queries) for more information). The notion
of instance healthiness is directly tied to the state of processes running on a
VM. DNS release will continuously poll for updated healthiness information (same
information is visible via `bosh instances --ps` command) on all instances from
groups that were resolved at least once.

To enable healthiness, use `health.enabled` property and specify necessary TLS certificates. Canonical DNS runtime config with healthiness enabled can be found here: https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml.

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

BOSH DNS provides its own structured query language for querying instances?
based on an instance's endemic and organizational relationship; e.g., by an
instance's healthiness, its availability zone, or group id.

An example of a DNS query is as follows:

```bash
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
