---
title: Native DNS Support [alpha]
---

<p class="note">Note: This feature is still under development; however, there are portions of DNS functionality that are already available in bosh-release v262+. 3421+ Linux stemcells are required.</p>

Using DNS instead of plain IPs within deployments:

- allows use of dynamic networks since IPs change with every redeploy
- provides a way to reference deployed VMs more transparently
- provides client side load balancing
- reduces number of configuration changes that need to be propagated when changing cluster layout

Historically BOSH users did not have an easy highly available solution to enable DNS for their deployments. PowerDNS was a possible choice; however, it required more advanced configuration that we felt comfortable recommending to everyone.

Addition of native BOSH DNS integration solves these problems without making it hard to deploy and operate DNS servers.

---
## <a id='arch'></a> Architecture

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

See [Deploying step-by-step](deploying-step-by-step.html) for full Director deployment flow.

---
## <a id='dns-release'></a> DNS release

To take advantage of native DNS functionality, it's expected that [DNS release](https://bosh.io/releases/github.com/cloudfoundry/dns-release?all=1) runs on each VM. We recommend to colocate DNS release by definiting it in an [addon](runtime-config.html#addons).

DNS release provides two jobs: `bosh-dns` (for Linux) and `bosh-dns-windows` (for Windows) which start a simple DNS server bound to a [link local address](https://bosh.io/jobs/bosh-dns?source=github.com/cloudfoundry/dns-release#p=address).

### <a id='aliases'></a> Aliases

DNS release allows operators to specify custom names for BOSH generated DNS records to ease migration or work with legacy software that requires very specific DNS record formats (e.g. `master0`, `slave0`, `slave1`).

There are two ways to specify aliases:

- via [`aliases` property](https://bosh.io/jobs/dns?source=github.com/cloudfoundry/dns-release#p=aliases)
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

See [Migrating from Consul](dns.html#migrate-consul) for more details.

### Healthiness

<p class="note">Note: This feature is not released yet.</p>

DNS release provides a way to reference all instances (or a subset of instances) in an instance group. By default only heatlhy instances are returned from a group query. The notion of instance healthiness is directly tied to the state of processes running on a VM. DNS release will continiously poll for updated healthiness information (same information is visible via `bosh instances --ps` command) on all instances from groups that were resolved at least once.

---
## <a id='enable'></a> Enabling DNS

To enable native BOSH functionality, you must first enable [`local_dns.enabled` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.enabled) in the Director job. See [bosh-deployment's local-dns.yml](https://github.com/cloudfoundry/bosh-deployment/blob/master/local-dns.yml) as an example.

Enabling `local_dns.enabled` configuration will make Director broadcast DNS updates to all VMs. Only VMs based on 3421+ Linux stemcells will accept DNS broadcast message.

If you were relying on instance index based DNS records, you must enable [`local_dns.include_index` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.enabled) in the Director job.

Additionally you should colocate DNS release via an addon in all your deployments. See [bosh-deployment's runtime-configs/dns.yml](https://github.com/cloudfoundry/bosh-deployment/blob/master/runtime-configs/dns.yml) as an example.

---
## <a id='links'></a> Impact on links

Each link includes some networking information about its provider. Addresses returned by a link may be either IP addresses or DNS addresses.

As of bosh-release v263 opting into DNS addresses in links must be done explicitly. Previous Director versions would opt into this behaviour by default.

You can control type of addresses returned at three different levels:

- for the entire Director via Director job configuration [`director.local_dns.use_dns_addresses` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.local_dns.use_dns_addresses) that if enabled affects all deployments by default. We are planning to eventually change this configuration to true by default.

- for a specific deployment via [`features.use_dns_addresses` deployment manifest property](manifest-v2.html#features) that if enabled affects links within this deployment

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
link("db").instances[0].address => "172.10.10.0"

# after
link("db").instances[0].address => "ef489dd9-48f6-45f0-b7af-7f3437919b17.db.default.db.bosh"
```

---
## <a id='job-address'></a> Impact on job's address (`spec.address`)

Similar to how [links are affected](dns.html#links), `spec.addres` will start returning DNS address once `use_dns_addresses` feature is enabled.

---
## <a id='migrate-powerdns'></a> Migrating from PowerDNS

Historically BOSH users did not have an easy highly available solution to enable DNS for their deployments. PowerDNS was a possible choice; however, it required more advanced configuration that we felt comfortable recommending to everyone. We are planning to deprecate and remove PowerDNS integration. To migrate from PowerDNS to native DNS:

1. continue deploying Director with `powerdns` job
1. enable native DNS (follow [Enabling DNS](dns.html#enable) section above) with proper recursors configured
1. redeploy all deployments and make sure that native DNS is in use
1. redeploy Director without `powerdns` job

---
## <a id='migrate-consul'></a> Migrating from Consul

To ease migration from Consul DNS entries, DNS release provides [aliases feature](dns.html#aliases). It allows operators to define custom DNS entries that can map to BOSH generated DNS entries. To migrate off of Consul to native DNS:

1. enable native DNS (follow [Enabling DNS](dns.html#enable) section above) with proper recursors configured
1. continue deploying `consul_agent` job
1. define native DNS aliases that match existing Consul DNS entries
1. redeploy all deployments that use Consul
1. redeploy all deployments without `consul_agent` job
