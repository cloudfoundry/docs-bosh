---
title: Jobs
---

Jobs are a realization of packages, i.e. running one or more processes from a package. A job contains the configuration files and startup scripts to run the binaries from a package.

There is a *many-to-many* mapping between jobs and VMs. One or more jobs can run in any given VM, and many VMs can run the same job. For example, four VMs are running the Cloud Controller job, and the Cloud Controller job and the DEA job can also run on the same VM. If you need to run two different processes (from two different packages) on the same VM, you need to create a job that starts both processes.

<a id="prepare-script"></a> Prepare Script
------------------------------------------

If a job needs to assemble itself from other jobs (like a super-job), you can use a `prepare` script. The script is run before the job is packaged up, and can create, copy, or modify files.

<a id="job-templates"></a> Job Templates
----------------------------------------

Job templates are generalized configuration files and scripts for a job. The job uses [ERB](http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html) files to generate the final configuration files and scripts when a Stemcell is turned into a job.

When a configuration file is turned into a template, instance-specific information is abstracted into a property that later is provided when the [Director](/bosh/terminology.html#director) starts the job on a VM. Information includes, for example, which port the webserver should run on, or which username and password a database should use.

The files are located in the `templates` directory, and the mapping between a template file and its final location is provided in the job `spec` file in the templates section. For example:

```
templates:
  foo_ctl.erb: bin/foo_ctl
  foo.yml.erb: config/foo.yml
  foo.txt: config/foo.txt
```

<a id="use-of-properties"></a> Use of Properties
------------------------------------------------

The properties used for a job comes from the deployment manifest, which passes the instance-specific information to the VM through the [agent](/bosh/terminology.html#agent).

Each template can use Ruby templating system ERb to insert properties and conditionally test if properties have been provided.

- `<%= "value" %>` - Inserts `value` into the template.
- `<%= p("some.property") %>` - Insert the property `some.property` from the deployment manifest, else a default value from the job template's `spec` file.
- `<% expression %>` - Evaluates `expression` but does not insert content into the template. Useful for `if`/`else`/`end` statements.
- `<% if_p("some.property") do |prop| %>` - Evaluates the block only if `some.property` property has been provided. The property is available in the variable `prop`. Multiple properties can be required: `<% if_p("prop1", "prop2") do |prop1, prop2| %>`

For advanced users, each job template can access the `spec` object to learn more about the deployment, BOSH and this VM:

- `<%= spec.deployment %>` - Inserts the current deployment name from the deployment manifest
- `<%= spec.dns_domain_name %>` - Inserts the root DNS domain name for BOSH DNS. This value can also be learned from running `bosh status`.
- `<%= spec.networks.send(spec.networks.methods(false).first).ip %>` - Inserts the IP of the first network bound to this VM (typically its the only network).

<a id="the-job-of-a-vm"></a> The Job of a VM
--------------------------------------------

When a VM is first started, it is a Stemcell, which can become any kind of job. It is first when the director instructs the VM to run a job as it will gets its *personality*.

<a id="monit-rc"></a> Monitrc
-----------------------------

BOSH uses [monit](http://mmonit.com/monit/) to manage and monitor the process(es) for a job. The `monit` file describes how the BOSH [agent](/bosh/terminology.html#agent) will stop and start the job, and it contains at least three sections:

`with pidfile`: Where the process keeps its pid file

`start program`: How monit should start the process

`stop program`: How monit should stop the process

Usually the `monit` file contains a script to invoke to start and stop the process, but it can invoke the binary directly.

Early in the development of a BOSH release, it may be useful to leave the `monit` file empty --- this does not cause a problem. You still must include a `monit` file, but it can simply be an empty file.
