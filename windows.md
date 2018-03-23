---
title: BOSH on Windows
---

BOSH can deploy jobs on Windows VMs. There is open source tooling and documentation available to build [AWS](https://github.com/cloudfoundry-incubator/aws-light-stemcell-builder), [Azure](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/blob/master/azure-light-stemcell.md),
[vSphere](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/blob/master/create-manual-vsphere-stemcells.md) and [Openstack](https://github.com/cloudfoundry-incubator/bosh-windows-stemcell-builder/blob/master/create-manual-openstack-stemcells.md) stemcells for Windows.

In general Windows BOSH Releases work in the same way as a standard BOSH release. The main difference is that the [monit file](create-release.md#monit) for Linux Releases is structured differently on Windows. Below are specific concerns for jobs on Windows.

---
## <a id="releases"></a> Releases

The structure of a BOSH release for Windows is identical to [Linux BOSH Releases](http://bosh.io/docs/create-release.html).  This means the structure of a Windows BOSH release will be:

- metadata that specifies available configuration options
- ERB configuration files
- a Monit file that describes how to start, stop and monitor processes
- start and stop scripts for each process
- additional hook scripts

---
## <a id="jobs"></a> Jobs

The structure of a BOSH job for Windows is similar to the [Standard Linux BOSH Job Lifecycle](http://bosh.io/docs/job-lifecycle.html), only with processes monitored by [Windows Service Wrapper](https://github.com/kohsuke/winsw) instead of monit.

The monit file for Windows is a JSON config file that describes processes to run:

```json
{
  "processes": [
    {
      "name": "say-hello",
      "executable": "powershell",
      "args": [ "/var/vcap/jobs/say-hello/bin/start.ps1" ],
      "env": {
        "FOO": "BAR"
      }
    }
  ]
}
```

The above monit file will execute the file `C:\var\vcap\jobs\say-hello\bin\start.ps1` with the environment variable `FOO` set to `BAR`. The BOSH agent ensures the process is running by executing within a [service wrapper](https://github.com/kohsuke/winsw).

Also, note that Pre-Start, Post-Start, Drain, and Post-Deploy scripts (described in the [job lifecycle](http://bosh.io/docs/job-lifecycle.html)) must be powershell scripts and end with the `.ps1` extension, i.e., `pre-start.ps1`, `post-start.ps1`, `drain.ps1`, and `post-deploy.ps1`.

---
### <a id="stop-scripts"></a> Stop Scripts in Jobs

Release job can have a stop script that will run when the job is restarted or stopped. This script allows the job to clean up and get into a state where it can be safely stopped.

The stop script replaces the standard mechanism for shutting down a BOSH job. If you use a stop script, [winsw](https://github.com/kohsuke/winsw) will *not* stop your job automatically. Instead it is the responsibility of the stop script to clean up resources and kill any processes that are part of the job. Winsw will wait for both the stop script and the main job process to exit before reporting to Windows that the service has terminated. For more details on how winsw handles a stop script, see [winsw documentation](https://github.com/kohsuke/winsw/blob/master/doc/xmlConfigFile.md#stopargumentstopexecutable).

To use a stop script, a change to the job's `monit` and `spec` file must be made. The actual script source is placed in the jobs template directory. eg: `jobs/job_name/templates`

Stdout and Stderr are currently not preserved. It is recommended to use the Windows EventLog.


### Monit

Monit changes can refer to separate scripts for both stop and start actions.
For instance, to use separate scripts for start and stop:

```json
{
  "processes": [
    {
      "name": "say-hello",
      "executable": "powershell.exe",
      "args": [ "/var/vcap/jobs/say-hello/bin/start.ps1" ],
      "stop": {
        "executable": "powershell.exe",:
        "args": [ "/var/vcap/jobs/say-hello/bin/stop.ps1" ],
      }
    }
  ]
}
```

### Spec

The `spec` file change is similar to linux. Here is an example:

```
---
name: simple-stop-example
templates:
  stop.ps1: bin/stop.ps1
```
---
## Sample BOSH Windows Release

Please see [the next page](windows-sample-release.md) for a sample BOSH Windows release.
