!!! note
    This feature is available with bosh-release v255.5+.

Previously, if network communication was required between jobs, release authors had to add job properties to accept other job's network addresses (e.g. a `db_ips` property). Operators then had to explicitly assign static IPs or DNS names for each instance group and fill out network address properties. Such configuration typically relied on some helper tool like spiff or careful manual configuration. It also led to inconsistent network configuration as different jobs named their properties differently. All of that did not make it easy to automate and operate multiple environments.

Links provide a solution to the above problem by making the Director responsible for the IP management. Release authors get a consistent way of retrieving networking (and topology) configuration, and operators have a way to consistently connect components.

---
## Overview {: #overview }

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

```shell
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

And then in the deployment manifest, we disambiguate the links with `provides` and `consumes` declarations on the jobs. The database instance groups name their `database_conn` links. The application job uses these names to specify which database it will use for each of its links.

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
## Release Definitions {: #definition }

Instead of defining properties for every instance group, a job can declare links. (The job either 'consumes' a link provided by another job, or it can 'provide' itself so that any jobs, [including itself](#self) can 'consume' it).

In the below yaml snippet the `name` field is used to differentiate between two links of the same `type` (`db`). Both the `name` and `type` that are provided can be arbitrarily defined by release authors. Other releases which consume these links must match the `type` specified.

For example, here is how a `web` job which receives HTTP traffic and talks to at least one database server may be defined. To connect to a database, it consumes `primary_db` and `secondary_db` links of type `db`. It also exposes an "incoming" link of type `http` so that other services can connect to it.

Note that when the `web` job is 'consuming' db links, the name of the link does not have to match the name of the provided db link (i.e. postgres has a link called `conn` while the `web` job consumes `primary_db` and/or `secondary_db`). The mapping between the provided link named `conn` and the consumed link named `primary_db` is done in the [deployment manifest file](#deployment).

#### `web` Release Spec {: #web-release-spec}
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

#### `postgres` Release Spec {: #postgres-release-spec}
```yaml
name: postgres

templates: {...}

provides:
- name: conn
  type: db

properties: {...}
```

### Template Accessors {: #templates }

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
* **address** [String, non-empty]: IPv4, IPv6 or DNS address. See [Native DNS Support](dns.md#links) for more details.
* **bootstrap** [Boolean]: Whether or not this instance is a bootstrap instance.

### Properties {: #properties }

See [link properties](links-properties.md) for including additional link information.

---
## Deployment Configuration {: #deployment }

Given the `web` and `postgres` job examples above, one can configure a deployment that connects a web app to the database. The following example demonstrates linking defined explicitly in the manifest by saying which jobs provide and consume a link `db_conn`.

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db: {from: db_conn}
      secondary_db: nil

- name: data_db
  jobs:
  - name: postgres
    release: postgres
    provides:
      conn: {as: db_conn}
```

### Implicit linking {: #implicit }

Implicit links are only defined in the release specification for the job, and are not mentioned in the `consumes` section of a job in the deployment manifest. This type of linking happens automatically. By default, links are implicit.

Implicit linking is not supported between deployments.

Providers that are specified as `nil` will not match any consumer.

Deployment Manifest:
```yaml
instance_groups:
- name: app_ig
  jobs:
  - name: db_job
    provides:
      database: nil
  - name: app
```

Unmatched consumers will cause the deployment to fail unless the consumer is defined as `optional` in the release. Optional links that can not be satisfied implicitly will return `nil` in the template rendering.

If a link `type` is provided by only one job within a deployment, all release jobs in that deployment that implicitly consume links of that `type` will resolve to that provider.

In the following example, it's unnecessary to specify explicitly that [web job](#web-release-spec) consumes the `primary_db` link of type `db` from the [postgres job](#postgres-release-spec), since the postgres job is the only one that provides a link of type `db`.

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

### Explicit Linking {: #explicit }

*Explicit linking* is defined as specifying the consumer in the deployment manifest. The consumer will be matched on both name and type.

There are two use cases that require the use of *explicit* linking.

* To distinguish between multiple providers of the same `type` in a deployment.
* To consume a link provided by a different deployment.


#### Consumers

Explicitly defined consumers can have the following optional properties:

* **from** [String]: Overrides the name of the provider to consume. This should match the name defined in the provider's release spec or the name defined by provider's `as` property in the manifest.
* **deployment** [String]: The name of the deployment to consume from. If the deployment provided does not exist, the consumer will fail with an error. The default value for this property is the name of the current deployment, which means that consumers are expected to be in the same deployment as the provider.
* **network** [String]: Network to be used by the consumer. This must match the name of one of the networks defined by the provider. The default value is the provider's default network. See [custom network linking](#custom-network).
* **ip_addresses** [Boolean]: Instructs the director to use ip addresses instead of DNS names. This property is ignored in the case of dynamic networks, which always use DNS addresses. Defaults to *false*. See [dns](dns.md#links) for more details.

Optional consumers may be specified as `nil` in the deployment manifest to block consumption of any providers.

Deployment Manifest:
```yaml
instance_groups:
- name: web_ig
  jobs:
  - name: web
    consumes:
      backup_db: nil
```

#### Providers

Explicitly specified providers in the deployment manifest can have the following optional properties:

* **as** [String]: Overrides the name of the provider defined in the release spec. Example:
```yaml
instance_groups:
- name: my_instance_group
  jobs:
  - name: postgres
    provides:
      conn: {as: new_name}
```
* **shared** [Boolean]: *Default is false* Sets whether this provider is consumable from another deployment. See [cross deployment links](#cross-deployment).

This applies whether the consumer is explicit or implicit.

##### Blocking a Link Provider {: #blocking-link-provider}

Providers that are specified as `nil` in the deployment manifest cannot be consumed. 

Deployment Manifest:
```yaml
instance_group:
- name: db_ig
  jobs:
  - name: postgres
    provides:
      conn: nil
```

A common use case for this is when a provider is optional and the current deployment will possibly use an alternative provider.


### Self linking {: #self }

A job can consume a link that it provides. This could be used to determine a job's own peers.

Implicit linking also applies.

```yaml
instance_groups:
- name: diego-etcd
  jobs:
  - name: etcd
    release: etcd
    consumes:
      etcd: {from: etcd-provider}
    provides:
      etcd: {as: etcd-provider}
```

[Example of self linking in Zookeeper release](https://github.com/cppforlife/zookeeper-release/blob/master/jobs/zookeeper/spec).

Common use cases:

- job is deployed across multiple instances and each node needs to communicate with other nodes

### Custom network linking {: #custom-network }

By default, links include network addresses on the producer's default link network. The default link network is a network marked with `default: [gateway]`. A release job can also consume a link over a different network.

For example, this `web` job will receive `data_db`'s network addresses on its `vip` network, instead of receiving network addresses from the `private` network.

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    consumes:
      primary_db: {from: db_conn, network: vip}
      secondary_db: nil
  networks:
  - name: private

- name: data_db
  jobs:
  - name: postgres
    release: postgres
    provides:
      conn: {as: db_conn}
  networks:
  - name: private
    default: [gateway, dns]
  - name: vip
```

Common use cases:

- job is deployed on two networks, and each network can only route to other particular network; consuming job deployed on a particular network needs to receive specific addresses so that it can connect to providing job.

### Cross-deployment linking {: #cross-deployment }

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

### Custom Provider Definitions {: #custom-provider-definitions }

Additional link providers (called `custom providers`) can be defined for a job through the deployment manifest or runtime config. Each custom provider needs a name and a type. The name cannot already exist in the release spec.
Adding a custom provider for a job does not require any changes to the job's release; only deployment manifest changes are needed.

!!! note
    **Custom Provider Definitions** feature is available with bosh-release v267+.

In the example below, the job `web` in release `my-app` is now providing a link with name `my_custom_link` and type `my_custom_link_type`. This link can be now consumed like any other provided link.

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    custom_provider_definitions:
    - name: my_custom_link
      type: my_custom_link_type
```

Below, is an example for aliasing the custom provided link and marking it as `shared`:

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    provides:
      my_custom_link:
        as: my_explicit_custom_link
        shared: true
    custom_provider_definitions:
    - name: my_custom_link
      type: my_custom_link_type
```

Additionally, the custom provider can optionally specify which properties to share from the job release spec. Example:

```yaml
instance_groups:
- name: app
  jobs:
  - name: web
    release: my-app
    provides:
      my_custom_link:
        as: my_explicit_custom_link
        shared: true
    custom_provider_definitions:
    - name: my_custom_link
      type: my_custom_link_type
      properties:
      - port
      - url
```
___

## Avoiding Link Conflicts

When writing a manifest that contains multiple jobs that provide a link, deployment will sometimes fail because of conflicts stemming from the links' names and types. Here are two typical errors:

```
Failed to resolve link 'login' with alias 'provider_login' and type 'usernamepassword' from job 'consumer_job' in instance group 'consumer_ig'. Details below:
  - No link providers found
```

```
- Failed to resolve link 'provider' with alias 'alias1' and type 'provider' from job 'consumer' in instance group 'first_consumer'. Multiple link providers found:
  - Link provider 'provider' with alias 'alias1' from job 'provider' in instance group 'first_provider' in deployment 'simple'
  - Link provider 'provider' with alias 'alias1' from job 'provider' in instance group 'second_provider' in deployment 'simple'
```

How to prevent such errors depends on how the links are consumed. 

### No Consumers
As long as they are not consumed, multiple providers in a deployment manifest will never generate errors during deployment even if the names or types of the individual job providers are the same as each other.

| Provider Name | Provider Type | Allowed | Example (below)
|---------------|---------------|---------|--------------
| Same          | Same          | True    | `database` of type `db` in both `db_ig` and `backup_db_ig`
| Same          | Different     | True    | `peers` of type `db_peers` in `db_ig` and `peers` of type `legacy_db_peers` in `backup_db_ig`
| Different     | Same          | True    | `peers` in `db_ig` and `backup_peers` both of type `db` in `backup_db_ig`
| Different     | Different     | True    | `database` of type `db` and `backup_peers` of type `db_peers`


Example manifest for table above.
```yaml
instance_groups:
  - name: db_ig
    jobs:
    - name: db_job
  - name: backup_db_ig
    jobs:
    - name: db_job
      provides:
        peers: {as: backup_peers}
        legacy_peers: {as: peers}
```

### Implicit Consumers

Providers with different types can always be consumed **implicitly** without conflicts.

| Provider Name | Provider Type | Allowed  |
|---------------|---------------|----------|
| Same          | Same          |  False   |
| Same          | Different     |  True    |
| Different     | Same          |  False   |
| Different     | Different     |  True    |

As shown in the table only the type is used to match the link provider with the link consumer. When there is more than one link provider of the same type, changing the name of the provider in the deployment manifest is not sufficient. To fix the error, the alternatives are either to [block](#blocking-link-provider) all but one link providers of each type, or switch to explicit links.

### Explicit Consumer

Providers with different names or types can always be **explicitly** consumed without conflicts.

| Provider Name | Provider Type |  Allowed |
|---------------|---------------|----------|
| Same          | Same          |  False   |
| Same          | Different     |  True    |
| Different     | Same          |  True    |
| Different     | Different     |  True    |

Here is an example of the failing case from the above table, where `app` fails to consume `conn` because `db_ig`'s job `postgres` and `backup_db_ig`'s job `postgres` provide `conn` of type `db`.

```yaml
instance_groups:
  - name: db_ig
    jobs:
    - name: postgres
  - name: backup_db_ig
    jobs:
    - name: postgres
  - name: app_ig
    jobs:
    - name: app
      consumes:
        conn: {from: conn}
```

There are two possible ways to fix this:

* Add the `provides` section of the providing job in the release manifest to rename the link using the `as` property.
* Introduce a second release to provide a backup job with a different link name or type.

___

## Links FAQ

Q: What characters are valid for link names?<br/>
A: All Unicode characters can be used in names. However a name cannot begin with a colon (`:`).

Q: When are cross-deployment links resolved?<br/>
A: They are only resolved during a deployment of the consumer. The provider is ready for consumption after a successful deploy of the provider deployment.

Q: If a cross-deployment provider is deleted what happens to the consumer?<br/>
A: Consumers will continue to have access to the link until the consumer deployment is redeployed. Consumer VMs can be recreated without losing the links' values. On redeployment, links will no longer resolve if the provider is no longer available.

Q: Are releases the only entities that can provide and consume links?<br/>
A: No, there are other entities that can provide links, such as [manual links](links-manual.md), and [external links](links-api.md). There are also [custom link providers](links.md#custom-provider-definitions) which variables can use to [consume some DNS values](dns.md#dns-variables-integration).

