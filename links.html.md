---
title: Links
---

<p class="note">Note: This feature is available with bosh-release ?.</p>

Before links for a release job to communicate with another release job, release authors had to add properties to their releases to accept other job's network addresses (e.g. "db_ips"). Operators then had to explicitly assign static IPs or DNS names for each deployment job and fill out properties. Such configuration typically relied on some helper tool like spiff or manual configuration. It also lead to incosistent network configuration as different jobs named their properties differently. All of that did not make it easy to automate and operate multiple environments.

Links provide a solution to the above problem by making the Director be responsible for the IP management. Release authors get a consistent way to retrieve networking (and topology) configuration, and operators have a way to consistently connect components.

---
## <a id="definition"></a> Release Definitions

Instead of defining properties that accept list of IPs or DNS names, each release job can define links it consumes and provides.

For example here is how "web" release job which receives HTTP traffic and talks to at least one database server may be defined. To connect to a database it consumes "primary\_db" and "secondary\_db" links of type "db". It also exposes an "incoming" link of type "http" so that other services can connect to it.

```yaml
name: web

templates: {...}

consumes:
- name: primary_db
  type: db
- name: secondary_db
  type: db
  optional: true

provides:
- name: incoming
  type: http

properties: {...}
```

Note that "secondary\_db" link has been marked as optional, to indicate that "web" release job will work correctly even if operator does not provide "secondary_db" link. Providing "secondary\_db" link may enable some addtional functionality.

Example Postgres release job that provides "conn" link of type "db".

```yaml
name: postgres

templates: {...}

provides:
- {name: conn, type: db}

properties: {...}
```

### <a id="templates"></a> Template Accessors

Once release is configured to consume links, `link` template accessor allows to access link information such as instance names, AZs, IDs, network addresses, etc.

- `link("...")` allows to access linked instances and their properties
- `if_link("...")` allows to conditionally access link (useful for optional links)

Besides just collecting all network addresses, information available in a link such as AZs may be useful to determine which instances release job should be selectively communicating.

```ruby
<%=

result = {}

result["primary"] = link("primary_db").instances.map do |instance|
  {
    "name" => instance.name,
    "id" => instance.id,
    "index" => instance.index,
    "az" => instance.az,
    "address" => instance.address,
  }
end

if_link("secondary_db") do |secondary|
  result["secondary"] = secondary.instances.map do |instance|
    {
      "name" => instance.name,
      "id" => instance.id,
      "index" => instance.index,
      "az" => instance.az,
      "address" => instance.address,
    }
  end
end

JSON.dump(result)

%>
```

Available `instance` object methods:

* **name** [String, non-empty]: Instance name as configured in the deployment manifest.
* **id** [String, non-empty]: Unique ID.
* **index** [Integer, non-empty]: Unique numeric index. May have gaps.
* **az** [String or null, non-empty]: AZ associated with the instance.
* **address** [String, non-empty]: IPv4, IPv6 or DNS record.
* **bootstrap** [Boolean]: Whether or not this instance is a bootstrap instance.

---
## <a id="deployment"></a> Deployment Configuration

Given release job examples above ("web" and "postgres") one can configure a deployment that connects a web app to the database.

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db: {from: data_db}
      secondary_db: nil

- name: data_db
  jobs:
  - name: postgres
    release: postgres
    provides:
      conn: {as: data_db}
```

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      secondary_db: nil

- name: data_db
  jobs:
  - name: postgres
    release: postgres
```

### <a id="implicit"></a> Implicit linking

If a link type is provided by only one release job within a deployment, all release jobs in that deployment that consume links of that type will be implicitly connected to that provider.

Optional links are also implicitly connected; however, if no provider can be found, it continues to be `nil`.

Implicit linking does not happen across deployments.

In the following example, it's unnecessary to explicitly specify that web release job consumes "primary_db" link of type "db" from the postgres release job, since postgres release job is the only one that provides link of type "db".

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes: {secondary_db: nil}

- name: data_db
  jobs:
  - name: postgres
    release: postgres
```

### <a id="self"></a> Self linking

A release job can consume a link that it provides. It's could be used to determine its own peers.

Implicit linking also applies.

```yaml
instance_groups:
- name: diego-etcd
  jobs:
  - name: etcd
    release: etcd
    consumes:
      etcd: {from: diego-etcd}
    provides:
      etcd: {as: diego-etcd}
```

### <a id="self"></a> Custom network linking

By default links include network addresses on producer's default link network. The default link network is a network marked with `default: [gateway]`. Release job can consume a link over a different network.

For example "web" release job will receive "data_db"'s network addresses on its "vip" network, instead of receiving network addresses from "private" network.

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db: {from: data_db, network: vip}
      secondary_db: nil
  networks:
  - name: private

- name: data_db
  jobs:
  - name: postgres
    release: postgres
    provides:
      conn: {as: data_db}
  networks:
  - name: private
    default: [gateway, dns]
  - name: vip
```

### <a id="cross-deployment"></a> Cross-deployment linking

Links can be formed between jobs between different deployments as long as link is marked as `shared`.

Unlike links within a deployment, updating a link producing job in one deployment does not affect a link consuming job in another deployment until that deployment is redeployed. To do so run `bosh deploy` command.

Implicit linking does not happen across deployments.

Deployment that provides a database:

```yaml
name: data-dep
jobs:
- name: db
  jobs:
  - name: postgres
    release: postgres
    provides:
      conn: {as: db, shared: true}
```

App deployment that expects to use the database from the deployment above:

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db: {from: data-dep.db}
      secondary_db: nil
```
