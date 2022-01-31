!!! note
    Applies to CLI v2.

An environment consists of a Director and deployments that it orchestrates.

## `create-env` command {: #create-env }

`bosh create-env` command takes a deployment manifest as its input and idempotently converges the VM to its desired configuration:

- it may recreate a VM due to a stemcell difference, and
- it may recreate persistent disks and migrate the data

Here is an example output which shows creation of a new VM and deployment of the Director onto it:

```shell
bosh create-env bosh.yml --state=bosh.json -o ... -v ...
```

```text
Deployment manifest: 'bosh.yml'
Deployment state: 'bosh.json'

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

Uploading stemcell 'bosh-warden-boshlite-ubuntu-xenial-go_agent/0000'... Finished (00:00:14)

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
```

Once Director VM is created you can check its basic information:

```shell
bosh -e 10.0.0.6 --ca-cert <(bosh int creds.yml --path /director_ssl/ca) env
```

Instead of specifying Director VM address via `--environment` (`-e`) flag and a CA certificate via `--ca-cert` flag in subsequent commands, a local alias can be created for environment with `bosh alias-env` command.

```shell
bosh alias-env aws -e 10.0.0.6 --ca-cert <(bosh int creds.yml --path /director_ssl/ca)
```

Use `bosh envs` command to list local aliases:

```shell
bosh envs
```

```text
URL            Alias
10.0.0.6       aws
192.168.56.6   vbox

2 environments

Succeeded
```

Subsequent commands can just reference created alias.

```shell
bosh -e aws env
```

Alternatively you can set `export BOSH_ENVIRONMENT=aws` once instead of using `--environment` flag for each command.

---
## Deployment State {: #deployment-state }

`bosh create-env` command needs to remember resources it creates in the IaaS so that it can re-use or delete them at a later time. The deploy command stores current state of your deployment in a given state file (via `--state` flag) or implicitly in `<manifest>-state.json` file in the same directory as your deployment manifest.

This allows you to deploy multiple deployments with different manifests.

Do not delete state file unless you have already deleted your deployment (with `bosh delete-env <manifest>` or by manually removing the VM, disk(s), &amp; stemcell from the IaaS). We recommend placing the deployment state file and the deployment manifest under version control and saving changes any time after running the deploy or delete commands.

### Recovering Deployment State {: #recover-deployment-state }

If for some reason you've lost your deployment state file, or have not saved the updates from the last run of the deploy command:

1. Create a file a new deployment state file as `state.json`. Write out following contents:

  ```json
  {
      "current_vm_cid": "<VM_ID>",
      "current_disk_id": "disk1",
      "disks": [{ "id": "disk1", "cid": "<DISK_ID>" }]
  }
  ```

1. Replace `<VM_ID>` with the ID of the VM found in the IaaS. For example on AWS it may be `i-f62df90b`.

1. Replace `<DISK_ID>` with the ID of the persistent disk found in the IaaS. For example on AWS it may be `vol-6370ec29`.

1. Run `bosh create-env bosh.yml --state=state.json -o ... -v ...` which will recreate the VM and migrate the disk contents.

1. Save the deployment state file.

---
## `delete-env` command {: #delete-env }

`bosh delete-env` command idempotently deletes all previously created IaaS resources (VMs, disks, and stemcells). The command will try its best to not return an error, for example it ignores resources that were already deleted and retries on certain operations.

Here is an example output:

```shell
bosh delete-env bosh.yml --state=bosh.json -o ... -v ...
```

```text
Deployment manifest: 'bosh.yml'
Deployment state: 'state.json'

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

Started deleting deployment
  Waiting for the agent on VM 'eadd5540-2816-41c1-5ca3-672818e4f829'... Finished (00:00:00)
  Stopping jobs on instance 'unknown/0'... Finished (00:00:01)
  Unmounting disk '030015fc-4148-4313-5e17-608dc4b7aa76'... Finished (00:00:01)
  Deleting VM '1987aaea-eb8a-4905-54d3-88202ce550d4'... Finished (00:00:00)
  Deleting disk '030015fc-4148-4313-5e17-608dc4b7aa76'... Finished (00:00:00)
  Deleting stemcell '47017a4e-4a81-41cf-4afc-1121346d46b4'... Finished (00:00:01)
Finished deleting deployment (00:00:04)
```

---
## `stop-env` command {: #stop-env }

!!! note
    This command is available with CLI v6.4.0+.

`bosh stop-env` Stops jobs (processes) on the env instance. Does not affect VM state.

Here is an example output:

```shell
bosh stop-env bosh.yml --state=bosh.json -o ... -v ...
```

```text
Deployment manifest: 'bosh.yml'
Deployment state: 'state.json'

Started validating
  Validating deployment manifest... Finished (00:00:00)
Finished validating (00:00:00)

Started stopping deployment
  Waiting for the agent on VM 'i-0e2a198e560f84f90'... Finished (00:00:00)
  Running the pre-stop scripts 'unknown/0'... Finished (00:00:00)
  Draining jobs on instance 'unknown/0'... Finished (00:00:11)
  Stopping jobs on instance 'unknown/0'... Finished (00:00:00)
  Running the post-stop scripts 'unknown/0'... Finished (00:00:00)
Finished stopping deployment (00:00:11)

Succeeded
```

---
## `start-env` command {: #start-env }

!!! note
    This command is available with CLI v6.4.0+.

`bosh start-env` Starts jobs (processes) on the env instance. Does not affect VM state.

Here is an example output:

```shell
bosh start-env bosh.yml --state=bosh.json -o ... -v ...
```

```text
Deployment manifest: 'bosh.yml'
Deployment state: 'state.json'

Started validating
  Validating deployment manifest... Finished (00:00:00)
Finished validating (00:00:00)

Started starting deployment
  Waiting for the agent on VM 'i-0e2a198e560f84f90'... Finished (00:00:00)
  Running the pre-start scripts 'unknown/0'... Finished (00:00:01)
  Starting the agent 'unknown/0'... Finished (00:00:01)
  Waiting for instance 'unknown/0' to be running... Finished (00:00:51)
  Running the post-start scripts 'unknown/0'... Finished (00:00:01)
Finished starting deployment (00:00:55)

Succeeded
```
