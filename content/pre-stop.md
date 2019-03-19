(See [Job Lifecycle](job-lifecycle.md) for an explanation of when pre-stop scripts run.)

!!! tip "Beta Feature"
    The `pre-stop` script is available with bosh-release [TODO Morgan](https://linkToRelease) and only for releases deployed with `TODO Morgan` stemcells. Otherwise the `pre-stop` script will be ignored and does not run before stop.

Release job can have a pre-stop script that will run before a [drain script](drain.md) is called. Similarly to the drain script, the pre-stop script also allows the job to prepare the release job for a graceful shutdown.
However unlike the drain script, during execution of the pre-stop script the release authors are exposed to more information related to future state of the VM, its instance and the whole deployment.
This new information is exposed to enable the release author to better manage their jobs before an eventual shutdown or a restart. These environment variables are explained further below.

---
## Job Configuration {: #job-configuration }

To add a pre-stop script to a release job:

1. Create a script with any name in the templates directory of a release job.
1. In the `templates` section of the release job spec file, add the script name and the `bin/pre-stop` directory as a key value pair.

Example:

```yaml
---
name: cassandra_node
templates:
  pre-stop.erb: bin/pre-stop
```

---
## Script Implementation {: #script-implementation }

A pre-stop script is usually just a regular shell script. Since the pre-start script is executed in a similar way to other release job scripts (start, stop, drain scripts) you can use the job's package dependencies.

The pre-stop script also uses an exit code to indicate its success (exit code 0) or failure (any other exit code). A pre-stop script should be idempotent.

---
## Environment Variables {: #environment-variables }

Pre-stop script can access the following environment variables:

* `BOSH_VM_NEXT_STATE` either `keep` if the VM will be the same VM that start is called on after the stop process, or `delete` if after stop process the VM will be deleted.
* `BOSH_INSTANCE_NEXT_STATE` either `keep` if the instance will be unaffected by the stop process, or `delete` if the instance is deleted after stop process is completed. If this is set to `delete`, the VM will be deleted and a replacement for it will not be created.
* `BOSH_DEPLOYMENT_NEXT_STATE` either `keep` if the deployment will remain after the stop process, or `delete` if the deployment is going to be deleted after completion of the stop process.

All possible cases of these environment variables:

| Values | Possible Causes |
| - | - |
|<code>BOSH_VM_NEXT_STATE = keep<br>BOSH_INSTANCE_NEXT_STATE = keep<br>BOSH_DEPLOYMENT_NEXT_STATE = keep</code> | Something on the VM is being updated<br>The VM will be kept |
|<code>BOSH_VM_NEXT_STATE = delete<br>BOSH_INSTANCE_NEXT_STATE = keep<br>BOSH_DEPLOYMENT_NEXT_STATE = keep</code> | Stemcell update or VM recreate|
|<code>BOSH_VM_NEXT_STATE = delete<br>BOSH_INSTANCE_NEXT_STATE = delete<br>BOSH_DEPLOYMENT_NEXT_STATE = keep</code> | Scaling down this instance|
|<code>BOSH_VM_NEXT_STATE = delete<br>BOSH_INSTANCE_NEXT_STATE = delete<br>BOSH_DEPLOYMENT_NEXT_STATE = delete</code> | Removing the entire deployment|


!!! note if `BOSH_DEPLOYMENT_NEXT_STATE` is set to `delete` then one can safely conclude that consequently both instance and its VM will also be deleted. Similarly, when `BOSH_INSTANCE_NEXT_STATE` is set to `delete` then the corresponding VM also will be deleted after the stop process.

A sample script of using these new environment variables may look similar to:

```bash
#!/bin/bash
echo "Running pre-stop script"

if [[ "${BOSH_VM_NEXT_STATE}" == "delete" ]] ; then
  // at the end of stop process this VM is going to be removed
  // eg. update_stemcell
fi

if [[ "${BOSH_INSTANCE_NEXT_STATE}" == "delete" ]] ; then
  // at the end of stop process this instance is going to be removed
  // eg. deregister_and_remove_data
fi

if [[ "${BOSH_DEPLOYMENT_NEXT_STATE}" == "delete" ]] ; then
  // at the end of stop process this deployment is going to be deleted
  // eg. shutdown_without_saving_data
fi

exit 0
```
