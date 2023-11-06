Each release job represents a specific chunk of work that the release performs. For example a DHCP release may have a "dhcp-server" job, and a Postgres release may have "postgres" and "periodic-backup" jobs. A release can define one or more jobs.

A job typically includes:

- metadata that specifies available configuration options
- ERB configuration files
- a Monit file that describes how to start, stop and monitor processes
- start and stop scripts for each process
- additional hook scripts

Jobs are typically OS specific (Windows vs Linux); however, structure of a job remains same.

---
## Spec file (metadata) {: #spec }

Spec file defines job metadata. It will be interpreted by the Director when the release is uploaded and when it's deployed.

```yaml
---
name: http-server

description: This job runs a simple HTTP server.

templates:
  bpm.yml: config/bpm.yml
  config.json: config/config.json

packages:
- http-server

properties:
  listen_port:
    description: "Port to listen on"
    default: 8080
```

Schema:

* **name** [String, required]: Name of the job.
* **description** [String, optional]: Describes purpose of the job.
* **templates** [Hash, optional]: [Template files](#templates) found in the
  `templates` directory of the job (keys of the Hash) and their final
  destinations (values of the Hash), relative to the job directory on the
  deployed VMs.
    * **&lt;key>** [String, required]: the relative path and filename of the
      ERB template provided by the job in the release, relative to the
      `templates` sub-directory. No need for any `.erb` suffix, all templates
      are treated as ERB templates whatever their name is.
    * **&lt;value>** [String, required]: the relative path and filename of the
      rendered file, relative to the job directory (i.e.
      `/var/vcap/jobs/<job-name>/`) on the managed Bosh instances (a.k.a. the
      “deployed VMs”). By convention, executable files should be placed into
      `bin/` directory so that the Agent can mark them as executables, and
      configuration files should be placed into `config/` directory.
* **packages** [Array, optional]: Package dependencies required by the job at runtime.
* **consumes** [Array, optional]: Links that are consumed by the job for
  rendering ERB templates.
    * **name** [String, required]: Name of the link to find.
    * **type** [String, required]: Type of the link to be found. This is an
      arbitrary naming. Usual and conventional types are `address` when the
      link goal is to expose a Bosh DNS name atht allows accessing the
      instances of the group. Usually typed by technology, like `mysql`,
      `postgres`, `cassandra`, etc. Anything that makes sense is relevant and
      matters.
    * **optional** [Boolean, optional]: Whether finding an matching link is
      optional (when `true`) or mandatory (when `false`. Default is `false`,
      so optinal links must be explicitly declared as such.
* **provides** [Array, optional]: Links that are exposed to other jobs for
  rendering their ERB templates.
    * **name** [String, required]: Name of the exposed link.
    * **type** [String, required]: Type of the exposed link.
    * **properties** [Array, optional]: List of property keys in dot notation
      (same as **properties.&lt;name>** below)
* **properties** [Hash, optional]: Configuration options supported by the job.
    * **&lt;name>** [String, required]: Property key in dot notation. Typical
      properties include account names, passwords, shared secrets, hostnames,
      IP addresses, port numbers, and descriptions.
        * **description** [String, required]: Describes purpose of the
          property. This is not used by the Director, but is displayed in job
          configuration details provided by the [release index](/releases).
        * **type** [String, optional]: The type of the property. This is only
          a convention for release authors to provide a type when they
          estimate it useful. Example: `type: certificate`.
        * **example** [Any, optional]: Example value, to be displayed in the
          [release index](/releases). Default is `nil`.
        * **default** [Any, optional]: The default value for the property.
          Default is `nil`.

!!! Note
    Within a peoperty definition, `default` is used by the Director, and
    `description`, `default` and `example` are displayed by the
    [release index](/releases). In turns, other keys like `type` are used only
    for convenience, like Concourse does `env` keys in the
    [“web” job definition][concourse_web_spec]. Indeed, the schema is not
    formally validated by the Director when registering a release job.

[concourse_web_spec]: https://github.com/concourse/concourse-bosh-release/blob/8d2cfa0/jobs/web/spec#L68-L71

---
## Templates (ERB configuration files) {: #templates }

Release authors can define zero or more templates for each job, but typically
you need at least a template for the BPM config file, that is expected to
renderd to the `config/bpm.yml` location.

### Favor Bosh Process Manager (BPM) over Monit {: #monit }

Monit is a component of the Bosh architecture that was introduced in the early
days, and has always been deemed to get rid of soon. But history has shown
over the years that transitionning away from Monit is complex-engough for
being hold back since then.

As a consequence, Release authors should avoid at all costs relying on fancy
Monit features. Instead, they should use a very simple and standard `monit`
file, and leverage the battle-tested and well-designed
[Bosh Process Manager (BPM)](bpm/bpm).

Whenever BPM would miss some required features, then contributions should be
submitted as Pull Requests to [its Git repository][bpm_repo] so that more
use-case are covered.

[bpm_repo]: https://github.com/cloudfoundry/bpm-release/tree/master/src/bpm

#### BPM Configuration

The release needs to render a `config/bpm.yml` file following the
configuration schema defined in the BPM documentation. The schema is clean and
configuring BPM is straightforward. See [BPM Configuration Format](bpm/config)
for more details.

Here is a simple example `bpm.yml` config, showcased in the
[Exemplar Bosh Release][exemplar_bpm].

[exemplar_bpm]: https://github.com/cloudfoundry/exemplar-release/blob/latest/jobs/sample-app/templates/bpm.yml

```yaml
<% require "json" -%>
processes:
  - name: sample-app
    executable: /var/vcap/packages/sample-app/bin/sample-app
    args: []
    env:
      PORT: <%= p('port').to_json %>
      CF_INSTANCE_INDEX: <%= spec.index.to_json %>
```

Release author need a basic understanding of the isolation mechanisms enforced
by BPM, especially read-only root disk remouting, and declarating read-write
access to portions only of the mount space.

See the [BPM Runtime Environment](bpm/runtime) for more details on these topics.

#### Standard `monit` shim with BPM

Here is the standard `monit` file that Release authors should use. Only
replace `<job-name>` by the actual job name.

```monit
check process <job-name>
  with pidfile /var/vcap/sys/run/bpm/<job-name>/<job-name>.pid
  start program "/var/vcap/jobs/bpm/bin/bpm start <job-name>"
  stop program "/var/vcap/jobs/bpm/bin/bpm stop <job-name>"
  group vcap
```

#### Legacy pattern with `*_ctl` script (highly discouraged)

Legacy `monit` files are using a `*_ctl` scripts that conventionally accept
`start` or `stop` as first argument. We document this here only for release
author to spot this old pattern and properly
[transition to the BPM pattern](bpm/transitioning).

```monit
check process postgres
  with pidfile /var/vcap/sys/run/postgres/postgres.pid
  start program "/var/vcap/jobs/postgres/bin/postgres_ctl start"
  stop program "/var/vcap/jobs/postgres/bin/postgres_ctl stop"
```

This is highly discouraged, because experience has show that the `*_ctl`
scripts have so many small details to care about, that this pattern leads to
tremendous boiler-plate, untested and fragile script code in Bosh releases.
Would release authors not be able to use BPM for some good reason, then
leveraging the standard `start-stop-daemon` utility is a cleaner and more
robust pattern.

For completeness, see the [Exemplar Release][start_stop_daemon_example] with
detailed examples on the `start-stop-daemon` pattern, though release authors
are encouraged to use BPM instead.

[start_stop_daemon_example]: https://github.com/cloudfoundry/exemplar-release/blob/latest/jobs/paragon/templates/start

#### Monit expectations

In a typical setup, BPM is called by Monit when OS processes, whether daemons
or one-off errand jobs, need to be started or stopped.

Monit expects that executing "bpm start" directive will get a process running
and output its PID into the file given by the `with pidfile` declaration. Once
the process is started by BPM, Monit will monitor the daemon process, based on
the PID that can be found in the `pidfile`, and if the process cease to exist,
Monit will try to start it again.

Monit also expects that executing `bpm stop` will stop the running process.
BPM offers the best guarantees for that, and properly adapts to some
documented defects of Monit in that regards.
See the [Monit Workarounds](bpm/runtime.md#monit-workarounds) for more details.

### Hook scripts {: #hooks }

There are several job lifecycle events that a job can react to: `pre-start`,
`post-start`, `post-deploy`, `pre-stop`, `post-stop`, and `drain`.

See [Job lifecycle](job-lifecycle.md) for more details on the exact execution
order of these hook scripts.

The Exemplar Release demonstrate state-of-the-art implementations for
[`post-start`][post_start_example] or [`drain`][drain_example], including
helpful boilerplate that provide proper timestamping of logs for hook scripts,
which has proven very useful when troubleshooting issues while developing Bosh
Releases.

[post_start_example]: https://github.com/cloudfoundry/exemplar-release/blob/latest/jobs/paragon/templates/post-start
[drain_example]: https://github.com/cloudfoundry/exemplar-release/blob/latest/jobs/paragon/templates/drain

### Use of Properties {: #properties }

Each template file is evaluated with [ERB](http://apidock.com/ruby/ERB) before being sent to each instance.

Basic ERB syntax includes:

- `<%= "value" %>`: Inserts string "value".
- `<% expression %>`: Evaluates `expression` but does not insert content into the template. Useful for `if/else/end` statements.
- `<% expression -%>`: Evaluates `expression`, does not insert any content,
  and remove the newline `\n` character that might be after the `-%>`.

Templates have access to merged job property values, built by merging default property values and operator specified property values in the deployment manifest. To access properties `p` and `if_p` ERB helpers are available:

- `<%= p("some.property") %>`: Insert the property `some.property` value, else a default value from the job spec file. If `some.property` does not have a default in the spec file, error will be raised to the user specifying that property value is missing.
Advanced usage:
    - Operator `p` can take optional parameter as a default value, e.g. `<%= p("some.property", some_value) %>`. This value is used as a last resort.
    - The first parameter can be an array, e.g.
      `<%= p(["some.property1", "some.property2"], some_value) %>`. Value of the
      first property which is set (i.e. non-`null`) will be returned.
- A part of the template can be evaluated only when some property is provided.
  `<% if_p("some.property") do |prop| %>...<% end %>` evaluates the block only
  if `some.property` property has been provided. The property value is
  available in the variable `prop`.
    - Multiple properties can be specified:
      `<% if_p("some.prop1", "other.prop2") do |prop1, prop2| %>...<% end %>`,
      in which case the block is evaluated only if _all_ the properties are
      defined.

After the `end` of an `if_p` block, the `.else ... end` and
`.else_if_p("other.property") ... end` syntaxes are supported.

- `<% if_p("some.property") do |prop| %>...<% end.else %>...<% end %>` -
  Evaluates first block if `some.property` has been provoded (or has a default
  in job spec), otherwise evaluates the second block.
- `<% if_p("some.property") do |prop| %>...<% end.else_if_p("other.property") |prop2| %>...<% end.else %>...<% end %>` -
  Evaluates first block if `some.property` has been provided (or has a default
  in job spec), otherwise evaluates the second block if `other.property` has
  been provided (or has a default in job spec), otherwise evaluates the third
  block.

The link navigation syntax `link()` also provides similar `.p()` and `.if_p()`
methods, and `.else_if_p()` or `.else` blocks.

- `<%= link("relation-name").if_p("remote.prop") do |prop| %>...<% end %>` -
  If `remote.prop` is defined in the job that is resolved through navigating
  the `relation-name` link, then the block is evaluated with the value in the
  local variable `prop`.
- `<%= link("relation-name").if_p("remote.prop") do |prop| %>...<% end.else %>...<% end %>` -
  Same as above with an `.else ... end` block.
- `<%= link("relation-name").if_p("remote.prop") do |prop| %>...<% end.else_if_p("other.prop2") |prop2| %>...<% end.else %>...<% end %>` -
  Same as above with an `.else_if_p` block that evaluates only when
  `other.prop2` is defined through navigating the `relation-name` link.

See [Links](links.md) and [Links Properties](links-properties.md) for more
details on navigating links to fetch configuration properties from other jobs,
possibly declared in different instance groups, and even possibly living in
different deployments.

#### Using `spec` {: #properties-spec }

Each template can also access the special `spec` object for instance-specific
configuration. Remember that job properties are initially defined at the
_instance group_ level in the deployment manifest.

Release authors can the `spec` object directly in the ERB templates:
`<%= spec.ip %>`.

The accessible properties fall into three categories: Bosh structure
information, networking setup, and instance configuration.

##### Structural info

- `spec.deployment`: Name of the BOSH deployment defining the instance group.
- `spec.name`: Name of the instance group that the instance belongs to.
- `spec.az`: The availability zone that the instance is placed into.
- `spec.id`: Unique and immutable UUID of the instance.
- `spec.index`: Ordinal and numeric “human friendly” instance index. Indexes
  usually start a `0`, but with no guarantee. Gaps may appear anywhere in the
  numbering, and the first instance in the group may have a non-zero index.
- `spec.bootstrap`: Boolean that is `true` if the instance is the first
  instance of its group.

!!! Note
    With `spec.index`, Bosh doesn't guarantee that instances will be numbered
    consecutively. Determining which instance is the first its group is a very
    common requirement, so that certain things get bootstrapped by one single
    node of a cluster, like database schema migrations, or admin password
    enforcement. When facing such requirement, release authors should not
    assume there is necessarily an instance with index `0`, and use
    `spec.bootstrap` instead.

##### Networking setup

- `spec.address`: Default network address for the instance. This can be an
  IPv4, an IPv6 address or a DNS record, depending on the Director's
  configuration. Available in bosh-release v255.4+.
- `spec.ip`: IP address of the instance. In case multiple IP addresses are
  available, the IP of the
  [addressable or default network](networks.md#multi-homed) is used. Available
  in bosh-release v258+.
- `spec.dns_domain_name`: the configured root domain name for the Director,
  which defaults to `bosh`, meaning that the configured Top-Level Domain (TLD)
  for Bosh DNS is `.bosh`.
- `spec.networks`: Entire set of network information for the instance. Example:

    ```yaml
    <network-name>:
        type: manual
        ip: 10.224.0.129
        netmask: 255.255.240.0
        cloud_properties:
          name: random
        default:
        - dns
        - gateway
        gateway: 10.224.0.1
        dns_record_name: 0.<instance-group>.<network>.<deployment>.bosh
    ```

!!! Note
    Release authors are encouraged to favor `spec.address` over `spec.ip`. The
    `spec.ip` property is provided only for use-cases where a numeric IP
    address (either IPv4 or IPv6) is absolutely required.

!!! Warning
      When **dynamic** networks are being used, `spec.ip` might not be
      available, then the value `127.0.0.1` is provided instead. This applies
      to `spec.<network-name>.ip`, `spec.<network-name>.netmask` and
      `spec.<network-name>.gateway`.

##### Instance configuration

- `spec.persistent_disk`: is `0` if no persistent disk is mounted to the
  instance. In case the deployment manifest does declare a persistent disk
  attached to the instances of the group, this `persistent_disk` is given a
  `0` value when the deployment manifests instructs to remove the instance
  from the group and delete it (typical for _scaled-in_ operations, as opposed
  to _scale-out_ where new instances are “horizontally” added to a group).
- `spec.release.name`: The name of the BOSH Release where the instance job is
  originally defined.
- `spec.release.version`: Version of the BOSH release that the instance job
  relies on.

##### Link properties

Remember that the job targeted through alink can live in a different instance
group of a different deployment.

- Structural info
  - `link(name).deployment_name`: Deployment name of the linked job.
  - `link(name).instance_group`: Instance group name of the linked job.
  - `link(name).group_name`: A concatenation of the link name and link type,
    separated by a dash `-`, i.e. `<link-name>-<link-type>`.
  - `link(name).instances`: An array of details for each instance of the group.
  - `link(name).instances[].az`: the availability zone hat the instance is
    placed into
  - `link(name).instances[].name`: instance group name. Alias for
    `link().instance_group`.
  - `link(name).instances[].id`: instance immutable UUID
  - `link(name).instances[].index`: human-friendly instance ordinal
  - `link(name).instances[].bootstrap`: whether the instance is the first of
    its group
- Networking setup
  - `link(name).default_network`: default network for the instance group.
  - `link(name).networks`: list of all networks for the instance group. **TO BE TESTED**
  - `link(name).address`: an address for the instance group, using the `q-s0`
    prefix, indicating the `smart` health filter.
    See [Native DNS Support](dns.md) for more details.
  - `link(name).domain`: the root top-level domain name suffix. Defaults to `bosh`.
  - `link(name).use_link_dns_names`: applicable config for the link. **TO BE TESTED**
  - `link(name).use_short_dns_addresses`: applicable config for the link. **TO BE TESTED**
  - `link(name).instances[].address`: the instance address, that can be an
     IPv4, an IPv6 address or a DNS record, depending on the Director's
     configuration, but is usually a DNS name, ending with the suffix
     indicated in the `link().domain` property.
  - `link(name).instances[].addresses`: several addresses including aliases? **TO BE TESTED**
  - `link(name).instances[].dns_addresses`: same as above, but preferring DNS entry
- Configuration
  - `link(name).properties`: The job properties that are exposed by the link.

##### Deprecated properties accessors

- `name`: the instance group name. Alias for `spec.name` (recommended).
- `index`: the instance index in its group. Alias for `spec.index` (recommended).
- `properties`: the job properties, as defined in the instance group. Alias
  for `spec.properties`. Doesn't provide elementary error reporting.
- `spec.properties`: The properties defined in the deployment manifest for the
  instance job that the templates belongs to. Accessing properties through
  this object leads to poor error reporting and is highly discouraged. Bosh
  Release authors should use the `p()` accessor instead, which implements
  proper error reporting, and properly prevents misconfiguration.

With Bosh v1, the term “job” was designating an “instance group”. The use of
`spec.job` in ERB templates could possibly be used by legacy Bosh releases but
its usage is highly discouraged. It is documented here only to help release
authors to migrate to the standardized `p()` property accessor.

- `spec.job`: instance group spec. This is an old Bosh v1 naming, when _job_
  did actually mean _instance group_. `nil` when no job is defined for the
  instance group.
- `spec.job.name`: name of the instance group that the template belongs to.
- `spec.job.template`: name of the first job in the instance group, which is
  only relevant if it is the “default errand”, a legacy “Bosh v1” concept
  before it was decided that any job that defines a `bin/run` script can be
  run as an errand.
- `spec.job.version`: version of the first job in the instance group, only
  relevant if it is the “default errand” (legacy concept).
- `spec.job.templates`: an array of jobs for the instance group
- `spec.job.templates.*.name`: name of the job
- `spec.job.templates.*.version`: version as defined in the release jobs manifests
- `spec.job.templates.*.sha1`: digital fingerprint of the job (nowadays with a
  `sha256:` prefix for SHA256)
- `spec.job.templates.*.blobstore_id`: where to find the job tarball in the
  Director's blobstore.
- `spec.job.templates.*.logs`: an empty array of logs files, related to the
  legacy `logs` hash in a release job spec, which is undocumented.
- `spec.properties_need_filtering`: Whether properties from other instance
  groups should not be exposed to this job. This is legacy, and should not be
  here.
