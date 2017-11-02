---
title: Post-start Script
---

(See [Job Lifecycle](job-lifecycle.html) for an explanation of when post-start scripts run.)

<p class="note">Note: This feature is available with bosh-release v255.4+ and only for releases deployed with 3125+ stemcells.</p>

<p class="note">Note: Releases that make use of post-start scripts and are deployed on older stemcells or with an older Director may potentially deploy; however, post-start script will not be called.</p>

Release job can have a post-start script that will run after the job is started (specifically after monit successfully starts a process). This script allows the job to execute any additional commands against a machine and/or persistent data before considering release job as successfully started.

---
## <a id="job-configuration"></a> Job Configuration

To add a post-start script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/post-start` directory as a key value pair.

Example:

```yaml
---
name: cassandra_node
templates:
  post-start.erb: bin/post-start
```

---
## <a id="script-implementation"></a> Script Implementation

Post-start script is usually just a regular shell script. Since post-start script is executed in a similar way as other release job scripts (start, stop, drain scripts) you can use job's package dependencies.

Post-start script should be idempotent. It may be called multiple times after process is successfully started.

Unlike a drain script, a post-start script uses an exit code to indicate its success (exit code 0) or failure (any other exit code).

Post-start script is called every time after job is started (ctl script is called) by the Director, which means that post-start script should perform its operations in an idempotent way.

<p class="note">Note: Running `monit start` directly on a VM will not trigger post-start scripts.</p>

Post-start scripts in a single deployment job (typically is composed of multiple release jobs) are executed in parallel.

---
## <a id="logs"></a> Logs

You can find logs for each release job's post-start script in the following locations:

- stdout in `/var/vcap/sys/log/<job-name>/post-start.stdout.log`
- stderr in `/var/vcap/sys/log/<job-name>/post-start.stderr.log`

Since post-start script will be called multiple times, new output will be appended to the files above. Standard [log rotation policy](job-logs.html#log-rotation) applies.

---
Next: [Post-deploy script](post-deploy.html)

Previous: [Pre-start script](pre-start.html)
