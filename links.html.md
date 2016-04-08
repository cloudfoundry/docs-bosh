---
title: Links
---

<p class="note">Note: This feature is available with bosh-release v255.5+.</p>

Perviously, if network communication was required between jobs, release authors had to add job properties to accept other job's network addresses (e.g. a "db_ips" property). Operators then had to explicitly assign static IPs or DNS names for each instance group and fill out network address properties. Such configuration typically relied on some helper tool like spiff or careful manual configuration. It also lead to inconsistent network configuration as different jobs named their properties differently. All of that did not make it easy to automate and operate multiple environments.

Links provide a solution to the above problem by making the Director responsible for the IP management. Release authors get a consistent way of retrieving networking (and topology) configuration, and operators have a way to consistently connect components.

---
## <a id="definition"></a> Release Definitions

Instead of defining properties for every instance group, a job can declare links. (The job either 'consumes' a link provided by another job, or it can 'provide' itself so that any jobs, [including itself](#self) can 'consume' it).

In the below yaml snippet the `name` field is used to differentiate between two links of the same `type` (`db`). Both the `name` and `type` that are provided can be arbitrarily defined by release authors. Other releases which consume these links must match the `type` specified.

For example, here is how a "web" job which receives HTTP traffic and talks to at least one database server may be defined. To connect to a database, it consumes `primary_db` and `secondary_db` links of type `db`. It also exposes an "incoming" link of type `http` so that other services can connect to it.

\*\*Note that when the `web`job is 'consuming' db links, the name of the link does not have to match the name of the provided db link (i.e. postgres has a link called `conn` while the web job consumes `primary_db` and/or `secondary_db`). The mapping between the provided link named `conn` and the consumed link named `primary_db` is done in the [deployment manifest file](#deployment).

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

\*\*Note that the `secondary_db` link has been marked as optional, to indicate that the "web" job will work correctly, even if the operator does not provide a "secondary_db" link. Providing the `secondary_db` link may enable some additional functionality.

Here is an example Postgres job that provides a `conn` link of type `db`.

```yaml
name: postgres

templates: {...}

provides:
- {name: conn, type: db}

properties: {...}
```

### <a id="templates"></a> Template Accessors

Once a release is configured to consume links, the `link` template accessor allows access to link information such as instance names, AZs, IDs, network addresses, etc.

- `link("...")` allows access to linked instances and their properties
- `if_link("...")` allows conditional access to a link (useful for optional links)

Besides just collecting all network addresses, links include information that may be useful for determining which instances should be selectively communicating (e.g. based on AZ affinity).

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

Given the "web" and "postgres" job examples above, one can configure a deployment that connects a web app to the database. The following example demonstrates linking defined explicitly in the manifest by saying which jobs provide and consume a link `data_db`.

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

### <a id="implicit"></a> Implicit linking

If a link type is provided by only one job within a deployment, all release jobs in that deployment that consume links of that type will be implicitly connected to that provider.

Optional links are also implicitly connected; however, if no provider can be found, they continue to be `nil`.

Implicit linking does not happen across deployments.

In the following example, it's unnecessary to explicitly specify that web job consumes the "primary_db" link of type "db" from the postgres release job, since the postgres job is the only one that provides a link of type "db".

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

A job can consume a link that it provides. This could be used to determine a job's own peers.

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

### <a id="custom-network"></a> Custom network linking

By default, links include network addresses on the producer's default link network. The default link network is a network marked with `default: [gateway]`. A release job can also consume a link over a different network.

For example, this "web" job will receive "data_db"'s network addresses on its "vip" network, instead of receiving network addresses from the "private" network.

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

Links can be formed between jobs from different deployments as long as the link is marked as `shared`.

Unlike links within a deployment, updating a link producing job in one deployment does not affect a link consuming job in another deployment *until* that deployment is redeployed. To do so, run the `bosh deploy` command.

Implicit linking does not happen across deployments.

Here is a deployment that provides a database:

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

Here is an app deployment that expects to use the database from the deployment above:

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
