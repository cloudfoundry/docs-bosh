---
title: Jobs
---

Each release job represents a specific chunk of work that the release performs. For example a DHCP release may have a "dhcp\_server" job, and a Postgres release may have "postgres" and "periodic\_backup" jobs. A release can define one or more jobs.

A job typically includes:

- metadata that specifies available configuration options
- ERB configuration files
- a Monit file that describes how to start, stop and monitor processes
- start and stop scripts for each process
- additional hook scripts

---
## <a id="spec"></a> Spec file (metadata)

Spec file defines job metadata. It will be interpreted by the Director when the release is uploaded and when it's deployed.

```yaml
---
name: http_server

description: This job runs a simple HTTP server.

templates:
  ctl.sh: bin/ctl
  config.json: config/config.json

packages:
- http_server

properties:
  http_server.listen_port:
    description: "Port to listen on"
    default: 8080
```

Schema:

* **name** [String, required]: Name of the job.
* **description** [String, optional]: Describes purpose of the job.
* **templates** [Hash, optional]: [Template files](#templates) found in the `templates` directory of the job and their final destinations relative to the job directory on the deployed VMs. By convention executable files should be placed into `bin/` directory so that the Agent can mark them as executable, and configuration files should be placed into `config/` director.
* **packages** [Array, optional]: Package dependencies required by the job at runtime.
* **properties** [Hash, optional]: Configuration options supported by the job.
    * **\<name\>** [String, required]: Property key in dot notation. Typical properties include account names, passwords, shared secrets, hostnames, IP addresses, port numbers, and descriptions.
        * **description** [String, required]: Describes purpose of the property.
        * **example** [Any, optional]: Example value. Default is `nil`.
        * **default** [Any, optional]: Default value. Default is `nil`.

---
## <a id="templates"></a> Templates (ERB configuration files)

A template is a file that can b. Release author can define zero or more templates for each job, but typically you need at least a template for a control script.

### <a id="monit"></a> Monit

Example `monit` file for configuring single process that can start, monitor and stop a Postgres process:

<pre class="terminal">
check process postgres
  with pidfile /var/vcap/sys/run/postgres/pid
  start program "/var/vcap/jobs/postgres/bin/ctl start"
  stop program "/var/vcap/jobs/postgres/bin/ctl stop"
</pre>

### <a id="ctl"></a> Control script (`*_ctl` script)

In a typical setup, control script is called by the Monit when it tries to start, and stop processes.

Monit expects that executing "start program" directive will get a process running and output its PID into "pidfile" location. Once process is started, Monit will monitor that process is running and if it exits, it will try to restart it.

Monit also expects that executing "stop program" directive will stop running process when the Director is restarting or shutting down the VM.

### <a id="hooks"></a> Hook scripts

There are several job lifecycle events that a job can react to: pre-start, post-start, post-deploy, and drain. See [Job lifecycle](job-lifecycle.html) for the execution order.

### <a id="properties"></a> Use of Properties

Each template file is evaluated with [ERB](http://apidock.com/ruby/ERB) before being sent to each instance.

Basic ERB syntax includes:

- `<%= "value" %>`: Inserts string "value".
- `<% expression %>`: Evaluates `expression` but does not insert content into the template. Useful for `if/else/end` statements.

Templates have access to merged job property values, built by merging default property values and operator specified property values in the deployment manifest. To access properties `p` and `if_p` ERB helpers are available:

- `<%= p("some.property") %>`: Insert the property `some.property` value, else a default value from the job spec file. If `some.property` does not have a default in the spec file, error will be raised to the user specifying that property value is missing.
- `<% if_p("some.property") do |prop| %>...<% end %>` - Evaluates the block only if `some.property` property has been provided. The property value is available in the variable `prop`. Multiple properties can be specified: `<% if_p("prop1", "prop2") do |prop1, prop2| %>`.

Each template can also access special `spec` object for instance specific configuration:

- `<%= spec.job %>`: Inserts instance name.
- `<%= spec.id %>`: Inserts instance ID.

- `<%= spec.index %>`: Inserts instance index. Use `spec.bootstrap` instead of checking for index being 0.
- `<% spec.bootstrap %>`: Allow to evaluate if this instance is a the first instance of its group.

- `<%= spec.az %>`: Inserts instance AZ.
- `<%= spec.address %>`: Inserts default instance network address (IPv4, IPv6 or DNS record). Available in bosh-release ?+.
- `<% spec.networks %>`: Allows to evaluate instance's network information.
