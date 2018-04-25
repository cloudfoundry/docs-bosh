(See [Job Lifecycle](job-lifecycle.md) for an explanation of when drain scripts run.)

Release job can have a drain script that will run when the job is restarted or stopped. This script allows the job to clean up and get into a state where it can be safely stopped. For example, when writing a release for a load balancer, each node can safely stop accepting new connections and drain existing connections before fully stopping.

---
## Job Configuration {: #job-configuration }

To add a drain script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/drain` directory as a key value pair.

Example:

```yaml
---
name: nginx
templates:
  drain-web-requests.erb: bin/drain
```

!!! note
    Drain script from each release job will run if they are deployed on 3093+ stemcells. Before only the first release job's drain script ran.

---
## Script Implementation {: #script-implementation }

Drain script is usually just a regular shell script. Since drain script is executed in a similar way as other release job scripts (start, stop, pre-start scripts) you can use job's package dependencies.

Drain script should be idempotent. It may be called multiple times before or after process is stopped.

You must ensure that your drain script exits in one of following ways:

- exit with a non-`0` exit code to indicate drain script failed

- exit with `0` exit code and also print an integer followed by a newline to `stdout` (nothing else must be printed to `stdout`):

    **static draining**: If the drain script prints a zero or a positive integer, BOSH sleeps for that many seconds before continuing.

    **dynamic draining**: If the drain script prints a negative integer, BOSH sleeps for that many seconds, then calls the drain script again.

    !!! note
        BOSH re-runs a script indefinitely as long as the script exits with a exit code <code>0</code> and outputs a negative integer.

    !!! tip
        It's recommended to only use static draining as dynamic draining will be eventually deprecated.

Note that if drain script causes monitored job processes to exit, monit will not call stop script for that job.

---
## Environment Variables {: #environment-variables }

Drain script can access the following environment variables:

* `BOSH_JOB_STATE`: JSON description of the current job state
* `BOSH_JOB_NEXT_STATE`: JSON description of the new job state that is being applied

Currently, only persistent disk size is provided in those two variables. For
example:

```json
{"persistent_disk":2048}
```

With this, the `drain` script can determine when the size of the persistent
disk changes and take action.

But more importantly, it can detect when the current node is being deleted.
This is important when the node is part of a cluster and needs to gracefully
say goodbye to its pairs before leaving forever.

When the drain script is run before the node is deleted, then the new
persistent disk size is zero. For exemple, you would be able to see these
values when `echo`ing them.

```bash
$ cat /var/vcap/jobs/my-job/bon/drain
(
  echo BOSH_JOB_STATE=$BOSH_JOB_STATE
  echo BOSH_JOB_NEXT_STATE=$BOSH_JOB_NEXT_STATE
) \
  > /var/vcap/sys/log/my-job/drain.stdout.log
$ cat /var/vcap/sys/log/my-job/drain.stdout.log
BOSH_JOB_STATE={"persistent_disk":2048}
BOSH_JOB_NEXT_STATE={"persistent_disk":0}
```

You'll find [here](https://github.com/cloudfoundry-incubator/cfcr-etcd-release/blob/master/jobs/etcd/templates/bin/drain.erb)
an exemple script for an etcd member to leave its etcd cluster gracefully.


---
## Logs {: #logs }

Currently logs from the drain script are not saved on disk by default, though release author may choose to do so explicitly. We are planning to eventually make it more consistent with [pre-start script logging](pre-start.md#logs).

---
## Example {: #example }

```bash
#!/bin/bash

pid_path=/var/vcap/sys/run/worker/worker.pid

if [ -f $pid_path ]; then
  pid=$(cat $pid_path)
  kill $pid        # process is running; kill it softly
  sleep 10         # wait a bit
  kill -9 $pid     # kill it hard
  rm -rf $pid_path # remove pid file
fi

echo 0 # ok to exit; do not wait for anything

exit 0
```
