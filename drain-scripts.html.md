---
title: Drain Scripts
---
BOSH jobs can have drain scripts that will be run by BOSH when the job is
restarted or stopped. These scripts allow the job to clean up and get into a
state where it can be stopped.

## <a id="location"></a>Location ##

A job's drain script is found in `bin/drain` in the job's directory in the
release. It is usually listed as a template in the job's spec file:

~~~yaml
templates:
  drain.erb: bin/drain
~~~

## <a id="implementation"></a>Implementation ##

BOSH drain scripts can be written in any interpreted language found on the
job instance. The UNIX shebang line at the beginning is used to specify
the interpreter. Drain scripts are commonly implemented as shell scripts.

## <a id="environment-variables"></a>Environment Variables ##

The following environment variables are set in a drain script when it is running:

  * BOSH_JOB_STATE - JSON description of the current job state

  * BOSH_JOB_NEXT_STATE - JSON description of the new job state that is being
    applied

One use case for this feature is to determine if the size of the persistent
disk is being changed so the job can take appropriate action.

## <a id="dynamic-drain"></a>Dynamic Drain ##

A drain script can print a value to `stdout` to tell BOSH whether it is
finished. If it prints `0` followed by a newline, the drain is finished. If it
prints a negative integer, BOSH will sleep for that many seconds and call the
drain script again. If it prints a positive integer, BOSH will sleep for that
many seconds and then stop draining.

Drain scripts will continue being called as long as the script outputs a
negative value. There is no automatic timeout.

## <a id="example"></a>Example ##

~~~sh
#!/bin/sh

if [ ! -f /var/run/worker.pid ]; then
  # worker not running, ok to exit
  echo 0
else
  # worker still running, sleep for 5 seconds and and check again
  echo -5
fi
~~~
