(See [Job Lifecycle](job-lifecycle.md) for an explanation of when post-stop scripts run.)

!!! note
    This feature is available with bosh-release v265+ and only for releases deployed with 3125+ stemcells.

Release job can have a post-stop script that will run when the job is restarted or stopped. This script will run following a monit stop for all jobs on the VM in parallel.

---
## Job Configuration {: #job-configuration }

To add a post-deploy script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/post-stop` directory as a key value pair.

Example:

```yaml
---
name: cassandra_node
templates:
  post-stop.erb: bin/post-stop
```

---
## Script Implementation {: #script-implementation }

Post-stop script is usually just a regular shell script. Since post-start script is executed in a similar way as other release job scripts (start, stop, drain scripts) you can use job's package dependencies.

Post-stop script should be idempotent. It may be called multiple times after a process is stopped.
