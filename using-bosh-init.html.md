---
title: Using bosh-init
---

<p class="note">Note: See [CLI v2](cli-v2.html) for an updated CLI.</p>

(See [Install bosh-init](install-bosh-init.html) to set up bosh-init on your machine.)

bosh-init is used for creating and updating the Director (its VM and persistent disk) in an environment. To use bosh-init you need to create a deployment manifest that describes how to configure the Director. See [Bootstrapping an environment](init.html) for more details how to write a deployment manifest.

## <a id='deploy-cmd'></a> Deploy command

Deploy command takes a deployment manifest as its input and idempotently converges the VM to its desired configuration:

- it may recreate a VM due to a stemcell difference, and
- it may recreate persistent disks and migrate the data

<p class="note">Note: See <a href="migrate-to-bosh-init.html">Migrating to bosh-init from the micro CLI plugin</a> if you have an existing MicroBOSH.</p>

Here is an example output which shows creation of a new VM and deployment of the Director onto it:

<pre class="terminal wide">
$ bosh-init deploy bosh.yml
Deployment manifest: '/home/vagrant/bosh.yml'
Deployment state: '/home/vagrant/bosh-state.json'

Started validating
  Downloading stemcell...  Finished (00:00:02)
  Validating stemcell... Finished (00:00:04)
  Downloading release 'bosh'...  Finished (00:00:01)
  Downloading release 'bosh-warden-cpi'...  Finished (00:00:01)
  Validating releases... Finished (00:00:03)
  Validating deployment manifest... Finished (00:00:00)
  Validating cpi release... Finished (00:00:00)
Finished validating (00:00:07)

Started installing CPI
  Compiling package 'golang_1.3/fc3bc1b4431e8913d91362c1183c9852809d35f6'... Finished (00:00:10)
  Compiling package 'cpi/6f5b7e1d1050764cd14da9cc8e8683a03a502996'... Finished (00:00:04)
  Rendering job templates... Finished (00:00:00)
  Installing packages... Finished (00:00:01)
  Installing job 'cpi'... Finished (00:00:00)
Finished installing CPI (00:00:16)

Starting registry... Finished (00:00:00)

Uploading stemcell 'bosh-warden-boshlite-ubuntu-trusty-go_agent/0000'... Finished (00:00:14)

Started deploying
  Creating VM for instance 'bosh/0' from stemcell '47017a4e-4a81-41cf-4afc-1121346d46b4'... Finished (00:00:00)
  Waiting for the agent on VM '1987aaea-eb8a-4905-54d3-88202ce550d4' to be ready... Finished (00:00:01)
  Creating disk... Finished (00:00:00)
  Attaching disk '030015fc-4148-4313-5e17-608dc4b7aa76' to VM '1987aaea-eb8a-4905-54d3-88202ce550d4'... Finished (00:00:01)
  Compiling package 'ruby/8c1c0bba2f15f89e3129213e3877dd40e339592f'... Finished (00:01:32)
  Compiling package 'postgres/aa7f5b110e8b368eeb8f5dd032e1cab66d8614ce'... Finished (00:00:04)
  Compiling package 'nginx/8f131f14088764682ebd9ff399707f8adb9a5038'... Finished (00:00:33)
  Compiling package 'libpq/6aa19afb153dc276924693dc724760664ce61593'... Finished (00:00:14)
  Compiling package 'mysql/e5309aed88f5cc662bc77988a31874461f7c4fb8'... Finished (00:00:06)
  Compiling package 'redis/ec27a0b7849863bc160ac54ce667ecacd07fc4cb'... Finished (00:00:24)
  Compiling package 'powerdns/e41baf8e236b5fed52ba3c33cf646e4b2e0d5a4e'... Finished (00:00:01)
  Compiling package 'genisoimage/008d332ba1471bccf9d9aeb64c258fdd4bf76201'... Finished (00:00:16)
  Compiling package 'director/a59aa6cf382b0c6df4206219f9f661b86dfc6103'... Finished (00:00:37)
  Compiling package 'nats/6a31c7bb0d5ffa2a9f43c7fd7193193438e20e92'... Finished (00:00:09)
  Compiling package 'health_monitor/a8a4a1cb04f924f17f9944845f5f4a73ecd4b895'... Finished (00:00:18)
  Rendering job templates... Finished (00:00:00)
  Updating instance 'bosh/0'... Finished (00:00:09)
  Waiting for instance 'bosh/0' to be running... Finished (00:00:07)
Finished deploying (00:04:37)
</pre>

---
## <a id='deployment-state'></a> Deployment State

bosh-init needs to remember resources it creates in the IaaS so that it can re-use or delete them at a later time. The deploy command stores current state of your deployment in a `<manifest>-state.json` file in the same directory as your deployment manifest.

This allows you to deploy multiple deployments with different manifests.

Do not delete this file unless you have already deleted your deployment (with `bosh-init delete <manifest>` or by manually removing the VM, disk(s), &amp; stemcell from the IaaS). We recommend placing the deployment state file and the deployment manifest under version control and saving changes any time after running the deploy or delete commands.

### <a id='recover-deployment-state'></a> Recovering Deployment State

If for some reason you've lost your deployment state file, or have not saved the updates from the last run of the deploy command:

1. Create a file a new deployment state in the same directory as your deployment manifest and name it `<manifest>-state.json` (for example `bosh-state.json` if deployment manifest is `bosh.yml`). Write out following contents:

	```json
	{
	    "current_vm_cid": "<VM_ID>",
	    "current_disk_id": "disk1",
	    "disks": [{ "id": "disk1", "cid": "<DISK_ID>" }]
	}
	```

1. Replace `<VM_ID>` with the ID of the VM found in the IaaS. For example on AWS it may be `i-f62df90b`.

1. Replace `<DISK_ID>` with the ID of the persistent disk found in the IaaS. For example on AWS it may be `vol-6370ec29`.

1. Run `bosh-init deploy bosh.yml` which will recreate the VM and migrate the disk contents.

1. Save the deployment state file.

---
## <a id='delete-cmd'></a> Delete command

Delete command idempotently deletes all previously created IaaS resources (VMs, disks, and stemcells). The command will try its best to not return an error, for example it ignores resources that were already deleted and retries on certain operations.

Here is an example output:

<pre class="terminal wide">
$ bosh-init delete bosh.yml
Deployment manifest: '/home/vagrant/bosh.yml'
Deployment state: '/home/vagrant/bosh-state.json'

Started validating
  Downloading stemcell...  Finished (00:00:02)
  Validating stemcell... Finished (00:00:04)
  Downloading release 'bosh'...  Finished (00:00:01)
  Downloading release 'bosh-warden-cpi'...  Finished (00:00:01)
  Validating releases... Finished (00:00:03)
  Validating deployment manifest... Finished (00:00:00)
  Validating cpi release... Finished (00:00:00)
Finished validating (00:00:07)

Started installing CPI
  Compiling package 'golang_1.3/fc3bc1b4431e8913d91362c1183c9852809d35f6'... Finished (00:00:10)
  Compiling package 'cpi/6f5b7e1d1050764cd14da9cc8e8683a03a502996'... Finished (00:00:04)
  Rendering job templates... Finished (00:00:00)
  Installing packages... Finished (00:00:01)
  Installing job 'cpi'... Finished (00:00:00)
Finished installing CPI (00:00:16)

Starting registry... Finished (00:00:00)

Started deleting deployment
  Waiting for the agent on VM 'eadd5540-2816-41c1-5ca3-672818e4f829'... Finished (00:00:00)
  Stopping jobs on instance 'unknown/0'... Finished (00:00:01)
  Unmounting disk '030015fc-4148-4313-5e17-608dc4b7aa76'... Finished (00:00:01)
  Deleting VM '1987aaea-eb8a-4905-54d3-88202ce550d4'... Finished (00:00:00)
  Deleting disk '030015fc-4148-4313-5e17-608dc4b7aa76'... Finished (00:00:00)
  Deleting stemcell '47017a4e-4a81-41cf-4afc-1121346d46b4'... Finished (00:00:01)
Finished deleting deployment (00:00:04)
</pre>

---
## <a id='logging'></a> Logging

Along with the UI output (STDOUT) and UI errors (STDERR), bosh-init can output more verbose logs.

Logging is disabled by default (`BOSH_INIT_LOG_LEVEL` defaults to NONE).

To enable logging, set the `BOSH_INIT_LOG_LEVEL` environment variable to one of the following values: DEBUG, INFO, WARN, ERROR, NONE (default)

Logs write to STDOUT (debug & info) & STDERR (warn & error) by default.

To write logs to a file, set the `BOSH_INIT_LOG_PATH` environment variable to the path of the file to create and/or append to.

