---
title: Drain Scripts
---

BOSH jobs can have drain scripts that BOSH runs when the job is
restarted or stopped. These scripts allow the job to clean up and get into a
state where it can be safely stopped.

## <a id="job-configuration"></a> Job Configuration ##

To add a drain script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/drain` directory as a key value pair.

Example:

~~~yaml
---
name: nginx
templates:
  drain-web-requests.erb: bin/drain
~~~

<p class="note"><strong>Notes</strong>:
  <ul>
    <li>BOSH currently only allows one drain script per release job.</li>

    <li>For a job that contains many colocated jobs, BOSH executes the drain script only of the first colocated job. See <a href="https://www.pivotaltracker.com/story/show/70697490">Pivotal Tracker</a> to know when multiple colocated drain scripts are supported.</li>
  </ul>
</p>

## <a id="script-implementation"></a> Script Implementation ##

You can write BOSH drain scripts in any interpreted language found on the
job instance. Job instances inherit languages through release packages.

Drain scripts are commonly implemented as shell scripts. The UNIX shebang line at the beginning is used to specify the interpreter.

You must ensure that your drain script exits in one of following ways:

- Exit with a non-`0` status code: This informs BOSH that draining failed.

- Exit with `0` status code: The drain script must also print an integer followed by a newline to `stdout`. BOSH interprets the `0` status code and integer as follows:

    **Static draining**: If the drain script prints a zero or a positive
	integer, BOSH sleeps for that many seconds before continuing.

    **Dynamic draining**: If the drain script prints a negative integer, BOSH
	sleeps for that many seconds, then calls the drain script again.

	<p class="note"><strong>Note</strong>: BOSH reruns a script indefinitely as long as the script exits with a status code <code>0</code> and outputs a negative integer.</p>


## <a id="environment-variables"></a> Environment Variables ##

When running, a drain script can access the following environment variables:

  * `BOSH_JOB_STATE`: JSON description of the current job state

  * `BOSH_JOB_NEXT_STATE`: JSON description of the new job state that is being
    applied

Use this feature to monitor job properties.
For example, a script can use this feature to determine if the size of the persistent disk changes and take a specified action.

## <a id="example"></a> Example ##

~~~sh
#!/bin/sh

pid_path=/var/vcap/sys/run/worker/worker.pid

if [ -f $pid_path ]; then
  pid=$(cat $pid_path)

  # process is running; kill it softly
  kill $pid

  # wait a bit
  sleep 10

  # kill it hard
  kill -9 $pid

  # remove pid file
  rm -rf $pid_path
fi

# ok to exit; do not wait for anything
echo 0
~~~
