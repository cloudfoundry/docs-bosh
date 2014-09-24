---
title: Drain Scripts
---

BOSH jobs can have drain scripts that BOSH runs when the job is
restarted or stopped. These scripts allow the job to clean up and get into a
state where it can be safely stopped.

## <a id="job-configuration"></a> Job Configuration ##

To add drain script to a release job:

1. create a script with any name in release job's templates director
1. reference created script in release job's and configure it to be become 
`bin/drain`

BOSH currently only allows to have one drain script per release job
and it must be configured to become `bin/drain` on deployed VMs.

Example release job spec file with a drain script:

~~~yaml
---
name: nginx
templates:
  drain-web-requests.erb: bin/drain
~~~

## <a id="script-implementation"></a> Script Implementation ##

BOSH drain scripts can be written in any interpreted language found on the
job instance (provided via release packages). The UNIX shebang line at the 
beginning is used to specify the interpreter. Drain scripts are commonly 
implemented as shell scripts.

Drain script must exit in one of two ways:

- exit with 0 status code to tell BOSH to look at printed timeout value

    In this scenario drain script must print an integer followed by a newline 
    to `stdout` to tell BOSH how long to wait.

    **Static draining**: If the drain script prints 0 or a positive integer, BOSH will sleep for that 
    many seconds once before moving onto its next step.

    **Dynamic draining**: If the drain script prints a negative integer, BOSH will sleep for that 
    many seconds and call the drain script again. Drain script will continue 
    being called as long as the script outputs a negative value. There is no 
    automatic timeout.

- exit with non-0 status code to tell BOSH that draining failed

## <a id="environment-variables"></a> Environment Variables ##

The following environment variables are available in a drain script when it is running:

  * `BOSH_JOB_STATE` - JSON description of the current job state

  * `BOSH_JOB_NEXT_STATE` - JSON description of the new job state that is being
    applied

One use case for this feature is to determine if the size of the persistent
disk is being changed so the job can take appropriate action.

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
