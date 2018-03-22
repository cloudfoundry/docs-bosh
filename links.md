---
title: Links
---

<p class="note">Note: This feature is available with bosh-release v255.5+.</p>

Previously, if network communication was required between jobs, release authors had to add job properties to accept other job's network addresses (e.g. a `db_ips` property). Operators then had to explicitly assign static IPs or DNS names for each instance group and fill out network address properties. Such configuration typically relied on some helper tool like spiff or careful manual configuration. It also led to inconsistent network configuration as different jobs named their properties differently. All of that did not make it easy to automate and operate multiple environments.

Links provide a solution to the above problem by making the Director responsible for the IP management. Release authors get a consistent way of retrieving networking (and topology) configuration, and operators have a way to consistently connect components.

---
## <a id="overview"></a> Overview

First, we provide an overview of the capabilities and logistics of links through a simple example. Here, we have two jobs: an application job and a database job. The database provides its connection information through a link, which the application consumes.

In the database job's spec file, it declares that it provides the connection information:

```yaml
# Database job spec file.
name: database_job
# ...
provides:
- name: database_conn
  type: conn
  # Links always carry certain information, like its address and AZ.
  # Optionally, the provider can specify other properties in the link.
  properties:
  - port
  - adapter
  - username
  - password
  - name

properties:
  port:
    default: 8080
# ...
```

Likewise, the application job's spec file declares that it consumes connection information:

```yaml
# Application job spec file.
name: application_job
# ...
consumes:
- name: database_conn
  type: conn
# ...
```

Then, in the application job's templates, it can use the connection information from the link:

```sh
#!/bin/bash
# Application's templated control script.
# ...
export DATABASE_HOST="<%= link('database_conn').instances[0].address %>"
export DATABASE_PORT="<%= link('database_conn').p('port') %>"
# ...
```

If the application uses two database connections, each provided by a separate database instance group, the link becomes ambiguous and we must resolve the ambiguity in the deployment manifest. In this case, the application job's spec file could look like:

```yaml
# Application job spec file.
name: application_job_two_db
# ...
consumes:
- name: frontend_database
  type: conn
- name: backend_database
  type: conn
```

And then in the deployment manifest, we disambiguate the links with `provides` and `consumes` declarations on the jobs. The database instance groupd name their `database_conn` links. The application job uses these names to specify which database it will use for each of its links.

```yaml
# ...
instance_groups:
- name: database_1
  jobs:
  - name: database_job
    release: ...
    provides:
      database_conn: {as: db1}
- name: database_2
  jobs:
  - name: database_job
    release: ...
    provides:
      database_conn: {as: db2}
- name: application_ig
  jobs:
  - name: application_job_two_db
    release: ...
    consumes:
      frontend_database: {from: db1}
      backend_database: {from: db2}
# ...
```

---
## <a id="definition"></a> Release Definitions

Instead of defining properties for every instance group, a job can declare links. (The job either 'consumes' a link provided by another job, or it can 'provide' itself so that any jobs, [including itself](#self) can 'consume' it).

In the below yaml snippet the `name` field is used to differentiate between two links of the same `type` (`db`). Both the `name` and `type` that are provided can be arbitrarily defined by release authors. Other releases which consume these links must match the `type` specified.

For example, here is how a `web` job which receives HTTP traffic and talks to at least one database server may be defined. To connect to a database, it consumes `primary_db` and `secondary_db` links of type `db`. It also exposes an "incoming" link of type `http` so that other services can connect to it.

Note that when the `web` job is 'consuming' db links, the name of the link does not have to match the name of the provided db link (i.e. postgres has a link called `conn` while the `web` job consumes `primary_db` and/or `secondary_db`). The mapping between the provided link named `conn` and the consumed link named `primary_db` is done in the [deployment manifest file](#deployment).

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

Note that the `secondary_db` link has been marked as optional, to indicate that the `web` job will work correctly, even if the operator does not provide a `secondary_db` link. Providing the `secondary_db` link may enable some additional functionality.

Here is an example Postgres job that provides a `conn` link of type `db`.

```yaml
name: postgres

templates: {...}

provides:
- name: conn
  type: db

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

Available `link` object methods:

* **address** [String]: Returns single DNS address representing link provider. Using single address is typically a more common way to reference a link provider instead of accessing individual instance addresses (for example, when connecting to a database). Example: `link("...").address`.
  * **azs** [Array of strings, optional]: Argument to filter instance addresses by AZ. Logical OR will be used between AZs when multiple AZs are specified. Example: `link("...").address(azs: [spec.az])`. Default: all instances are returned without AZ filtering.
* **p** [Anything]: Returns property value specified in a link. Works in the same way as regular `p` accessor.
* **instances** [Array of instances]: Returns list of instances included by this provider. Could be an empty array. See methods available on each instance below.

Available `instance` object methods:

* **name** [String, non-empty]: Instance name as configured in the deployment manifest.
* **id** [String, non-empty]: Unique ID.
* **index** [Integer, non-empty]: Unique numeric index. May have gaps.
* **az** [String or null, non-empty]: AZ associated with the instance.
* **address** [String, non-empty]: IPv4, IPv6 or DNS address. See [Native DNS Support](dns.html#links) for more details.
* **bootstrap** [Boolean]: Whether or not this instance is a bootstrap instance.

### <a id="properties"></a> Properties

See [link properties](links-properties.html) for including additional link information.

---
## <a id="deployment"></a> Deployment Configuration

Given the `web` and `postgres` job examples above, one can configure a deployment that connects a web app to the database. The following example demonstrates linking defined explicitly in the manifest by saying which jobs provide and consume a link `data_db`.

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

In the following example, it's unnecessary to explicitly specify that `web` job consumes the `primary_db` link of type `db` from the postgres release job, since the postgres job is the only one that provides a link of type `db`.

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

Common use cases:

- deployment contains multiple components that are expected to communicate between each other and there is no benefit for the operator to configure these connections explicitly

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

[Example of self linking in Zookeeper release](https://github.com/cppforlife/zookeeper-release/blob/master/jobs/zookeeper/spec).

Common use cases:

- job is deployed across multiple instances and each node needs to communicate with other nodes

### <a id="custom-network"></a> Custom network linking

By default, links include network addresses on the producer's default link network. The default link network is a network marked with `default: [gateway]`. A release job can also consume a link over a different network.

For example, this `web` job will receive `data_db`'s network addresses on its `vip` network, instead of receiving network addresses from the `private` network.

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

Common use cases:

- job is deployed on two networks, and each network can only route to other particular network; consuming job deployed on a particular network needs to receive specific addresses so that it can connect to providing job.

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
      primary_db: {from: db, deployment: data-dep}
      secondary_db: nil
```

Common use cases:

- one team is managing one deployment and wants to expose a link for other teams to consume in their deployments in a self service manner

---
Next: [Link properties](links-properties.html) or [Manual linking](links-manual.html).

[Back to Table of Contents](index.html#deployment-config)
