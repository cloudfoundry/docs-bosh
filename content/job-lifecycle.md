---
title: Job Lifecycle
---

There are several stages that all jobs (and their associated processes) on each VM go through during a deployment process:

## When start is issued {: #start }

1. Persistent disks are mounted on the VM if configured, and not already mounted

1. All jobs and their dependent packages are downloaded and placed onto a machine

1. [pre-start scripts](pre-start.md) run for all jobs on the VM in parallel
	- (waits for all pre-start scripts to finish)
	- does not time out

1. `monit start` is called for each process in no particular order
  - each job can specify zero or more processes
  - times out based on [`canary_watch_time`/`update_watch_time` settings](manifest-v2.md#update)

1. [post-start scripts](post-start.md) run for all jobs on the VM in parallel
	- (waits for all post-start scripts to finish)
	- does not time out

1. [post-deploy scripts](post-deploy.md) run for all jobs on *all* VMs in parallel
	- (waits for all post-deploy scripts to finish)
	- does not time out

Note that scripts should not rely on the order they are run. Agent may decide to run them serially or in parallel.

---
## When processes are running {: #running }

1. Monit will automatically restart processes that failed their associated checks
  - a common pattern used is a PID check

---
## When stop is issued (or before update and subsequent start happens) {: #stop }

1. `monit unmonitor` is called for each process

1. [drain scripts](drain.md) run for all jobs on the VM in parallel
	- (waits for all drain scripts to finish)
	- does not time out

1. `monit stop` is called for each process
  - times out after 5 minutes as of bosh v258+ on 3302+ stemcells

1. Persistent disks are unmounted on the VM if configured

---
Next: [Pre-start script](pre-start.md)
