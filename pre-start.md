---
title: Pre-start Script
---

(See [Job Lifecycle](job-lifecycle.md) for an explanation of when pre-start scripts run.)

<p class="note">Note: This feature is available with bosh-release v206+ (1.3072.0) and only for releases deployed with 3125+ stemcells.</p>

<p class="note">Note: Releases that make use of pre-start scripts and are deployed on older stemcells or with an older Director may potentially deploy; however, pre-start script will not be called.</p>

Release job can have a pre-start script that will run before the job is started. This script allows the job to prepare machine and/or persistent data before starting its operation. For example, when writing a release for Cassandra, each node will need to migrate format of SSTables. That procedure may be lengthy and should happen before the node can successfully start.

---
## Job Configuration <a id="job-configuration"></a>

To add a pre-start script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/pre-start` directory as a key value pair.

Example:

```yaml
---
name: cassandra_node
templates:
  pre-start.erb: bin/pre-start
```

---
## Script Implementation <a id="script-implementation"></a>

Pre-start script is usually just a regular shell script. ERB tags may be used for templating. Since pre-start script is executed in a similar way as other release job scripts (start, stop, drain scripts) you can use job's package dependencies.

<p class="note">After templating, the pre-start script must have its shebang on the first line.</p>

Pre-start script should be idempotent. It may be called multiple times before process is successfully started.

Unlike a drain script, a pre-start script uses an exit code to indicate its success (exit code 0) or failure (any other exit code).

Pre-start script is called every time before job is started (ctl script is called) by the Director, which means that pre-start script should perform its operations in an idempotent way.

<p class="note">Note: Running `monit start` directly on a VM will not trigger pre-start scripts.</p>

Pre-start scripts in a single deployment job (typically is composed of multiple release jobs) are executed in parallel.

---
## Logs <a id="logs"></a>

You can find logs for each release job's pre-start script in the following locations:

- stdout in `/var/vcap/sys/log/<job-name>/pre-start.stdout.log`
- stderr in `/var/vcap/sys/log/<job-name>/pre-start.stderr.log`

Since pre-start script will be called multiple times, new output will be appended to the files above. Standard [log rotation policy](job-logs.md#log-rotation) applies.

---
Next: [Post-start script](post-start.md)

Previous: [Job lifecycle](job-lifecycle.md)
