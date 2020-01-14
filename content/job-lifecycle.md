There are several stages that all jobs (and their associated processes) on each VM go through during a deployment process.

## When start is issued {: #start }

1. Persistent disks are mounted on the VM, if configured and not yet mounted

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

!!! note
    Scripts should not rely on the order they are run. Agent may decide to run them serially or in parallel.

---
## When processes are running {: #running }

1. Monit will automatically restart processes that failed their associated checks
	- a common pattern used is a PID check

---
## When stop is issued (or before update and subsequent start happens) {: #stop }

1. `monit unmonitor` is called for each process

1. [pre-stop scripts](pre-stop.md) run for all jobs on the VM in parallel
	- (waits for all pre-stop scripts to finish)
	- does not time out
	- requires minimum BOSH `v269.0.0` and stemcell `v315.x`

1. [drain scripts](drain.md) run for all jobs on the VM in parallel
	- (waits for all drain scripts to finish)
	- does not time out

1. `monit stop` is called for each process
	- times out after 5 minutes as of bosh v258+ on 3302+ stemcells

1. [post-stop scripts](post-stop.md) run for all jobs on the VM in parallel
	- (waits for all post-stop scripts to finish)
	- does not time out
	- requires bosh v265+

1. Persistent disks are unmounted on the VM, if configured

## Non-Bosh VM Operations

Any deployed VM may be rebooted due to infrastructure disruptions or other operations. In general, the deployment lifecycle hooks are _not_ executed. Only local monitoring is invoked to restart jobs.

1. The VM reboot occurs, and VM is successfully booted. OS processes and services start.
1. `monit` starts running
1. `monit` begins starting processes registered. The job's `start program` is executed as per the `monitrc` file.

!!! note
    `pre-start`, `post-start`, `post-deploy` are **not** executed, since the bosh lifecycle is not invoked. It is recommended that a job's `monitrc` `start program` perform all operations required to start a job without depending on `pre-start` executing.
