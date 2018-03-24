---
title: Post-deploy Script
---

(See [Job Lifecycle](job-lifecycle.md) for an explanation of when post-deploy scripts run.)

<p class="note">Note: This feature is available with bosh-release v255.4+ and only for releases deployed with 3125+ stemcells.</p>

<p class="note">Note: Releases that make use of post-deploy scripts and are deployed on older stemcells or with an older Director may potentially deploy; however, post-deploy script will not be called.</p>

Release job can have a post-deploy script that will run after all jobs in the deployments successfully started (and ran post-start scripts). This script allows the job to execute any additional commands against a whole deployment before considering deploy finished.

---
## Director Configuration <a id="director-configuration"></a>

Currently the Director does not run post deploy scripts by default. Use [`director.enable_post_deploy` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.enable_post_deploy) to enable running scripts.

---
## Job Configuration <a id="job-configuration"></a>

To add a post-deploy script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/post-deploy` directory as a key value pair.

Example:

```yaml
---
name: cassandra_node
templates:
  post-deploy.erb: bin/post-deploy
```

---
## Script Implementation <a id="script-implementation"></a>

Post-deploy script is usually just a regular shell script. Since post-deploy script is executed in a similar way as other release job scripts (start, stop, drain scripts) you can use job's package dependencies.

Post-deploy script should be idempotent. It may be called multiple times after process is successfully started.

Unlike a drain script, a post-deploy script uses an exit code to indicate its success (exit code 0) or failure (any other exit code).

Post-deploy script is called every time after job is started (ctl script is called) by the Director, which means that post-deploy script should perform its operations in an idempotent way.

<p class="note">Note: Running `monit start` directly on a VM will not trigger post-deploy scripts.</p>

Post-deploy scripts in a deployment are executed in parallel.

---
## Logs <a id="logs"></a>

You can find logs for each release job's post-deploy script in the following locations:

- stdout in `/var/vcap/sys/log/<job-name>/post-deploy.stdout.log`
- stderr in `/var/vcap/sys/log/<job-name>/post-deploy.stderr.log`

Since post-deploy script will be called multiple times, new output will be appended to the files above. Standard [log rotation policy](job-logs.md#log-rotation) applies.

---
Next: [Drain script](drain.md)

Previous: [Post-start script](post-start.md)
