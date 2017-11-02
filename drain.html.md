---
title: Drain Script
---

(See [Job Lifecycle](job-lifecycle.html) for an explanation of when drain scripts run.)

Release job can have a drain script that will run when the job is restarted or stopped. This script allows the job to clean up and get into a state where it can be safely stopped. For example, when writing a release for a load balancer, each node can safely stop accepting new connections and drain existing connections before fully stopping.

---
## <a id="job-configuration"></a> Job Configuration

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

<p class="note">Note: Drain script from each release job will run if they are deployed on 3093+ stemcells. Before only the first release job's drain script ran.</p>

---
## <a id="script-implementation"></a> Script Implementation

Drain script is usually just a regular shell script. Since drain script is executed in a similar way as other release job scripts (start, stop, pre-start scripts) you can use job's package dependencies.

Drain script should be idempotent. It may be called multiple times before or after process is stopped.

You must ensure that your drain script exits in one of following ways:

- exit with a non-`0` exit code to indicate drain script failed

- exit with `0` exit code and also print an integer followed by a newline to `stdout` (nothing else must be printed to `stdout`):

    **static draining**: If the drain script prints a zero or a positive integer, BOSH sleeps for that many seconds before continuing.

    **dynamic draining**: If the drain script prints a negative integer, BOSH sleeps for that many seconds, then calls the drain script again.

    <p class="note">Note: BOSH re-runs a script indefinitely as long as the script exits with a exit code <code>0</code> and outputs a negative integer.</p>

    <p class="note">Note: It's recommended to only use static draining as dynamic draining will be eventually deprecated.</p>

---
## <a id="environment-variables"></a> Environment Variables

Drain script can access the following environment variables:

* `BOSH_JOB_STATE`: JSON description of the current job state
* `BOSH_JOB_NEXT_STATE`: JSON description of the new job state that is being applied

For example drain script can use this feature to determine if the size of the persistent disk changes and take a specified action.

---
## <a id="logs"></a> Logs

Currently logs from the drain script are not saved on disk by default, though release author may choose to do so explicitly. We are planning to eventually make it more consistent with [pre-start script logging](pre-start.html#logs).

---
## <a id="example"></a> Example

<pre class="bash">
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
</pre>

---
[Back to Table of Contents](index.html#release)

Previous: [Post-deploy script](post-deploy.html)
