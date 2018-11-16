!!! note
    See [CLI v2](cli-v2.md) for an updated CLI.

This document lists the all CLI commands you use to perform system administration tasks.

---
## For Cluster Operators {: #cluster-operators }

Use these commands against the Director to manage deployments and associated assets.

### Director Location {: #director }

```shell
$ bosh target [DIRECTOR_URL] [ALIAS]
```

Connects to the Director URL/IP that you specify for ongoing communication. You can provide `ALIAS` to set an alias for the Director. Displays the currently targeted Director if you do not provide a URL.

```shell
$ bosh login [USERNAME] [PASSWORD]
```

Authenticates a user with the Director when you provide a username and password. Prompts for this information if you omit it.

```shell
$ bosh status [--uuid]
```

Displays the configuration file and deployment manifest in use, and information about the BOSH Director such as name, URL, version, current username, UUID, and CPI.

---
### Users {: #user }

Use these commands to create and delete users on the Director.

```shell
$ bosh create user [USERNAME] [PASSWORD]
```

Creates a user with the Director. Prompts you for a `USERNAME` and `PASSWORD` if you omit this information.

```shell
$ bosh delete user [USERNAME]
```

Deletes a specific user from the BOSH Director. Prompts you for a `USERNAME` if you omit this information.

---
### Releases {: #dir-release }

```shell
$ bosh releases [--jobs]
```

Displays the list of available releases.

```shell
$ bosh upload release [RELEASE_FILE] [--rebase] [--skip-if-exists]
$ bosh upload release RELEASE_URL
```

Uploads the file that you specify as a release. If you do not provide a `RELEASE_FILE`, you must run this command from a valid release directory.

```shell
$ bosh delete release NAME [VERSION] [--force]
```

Deletes a release and associated jobs, packages, compiled packages, and all package metadata. Fails if a deployment references this release.

```shell
$ bosh inspect release NAME/VERSION
```

Prints release jobs and packages and their associated blobstore records as known by the Director.

```shell
$ bosh export release NAME/VERSION OS/VERSION
```

Exports given release as a tarball, including compiled packages for stemcell that matches OS and version.

---
### Stemcells {: #dir-stemcells }

```shell
$ bosh stemcells
```

Displays the name, version, and CID of available stemcells.

```shell
$ bosh upload stemcell STEMCELL_PATH [--skip-if-exists]
$ bosh upload stemcell STEMCELL_URL
```

Uploads specified stemcell. See [stemcells section of bosh.io](http://bosh.io/stemcells) for all available stemcells.

```shell
$ bosh delete stemcell NAME VERSION [--force]
```

Deletes a stemcell and all associated compiled packages. Fails if any deployment references this stemcell.

---
### Cloud config {: #cloud-config }

```shell
$ bosh cloud-config
```

Displays current cloud config saved in the Director.

```shell
$ bosh update cloud-config FILE_PATH
```

Updates currently saved cloud config in the Director. See [cloud config description](cloud-config.md).

---
### Runtime config {: #runtime-config }

```shell
$ bosh runtime-config
```

Displays current runtime config saved in the Director.

```shell
$ bosh update runtime-config FILE_PATH
```

Updates currently saved runtime config in the Director. See [runtime config description](runtime-config.md).

---
### Deployment {: #deployment }

```shell
$ bosh deployments
```

Displays the list of created deployments on the Director. Shows stemcells and releases used by each deployment.

```shell
$ bosh deployment [FILE_PATH]
```

Switches the CLI to operate on the deployment specified by the deployment manifest `FILE_PATH`. Displays the current deployment if you omit `FILENAME`.

```shell
$ bosh deploy [--recreate]
```

Creates/updates or recreates a deployment.

```shell
$ bosh download manifest DEPLOYMENT_NAME [FILE_PATH]
```

Downloads and saves the deployment manifest of the deployment `DEPLOYMENT_NAME` to `FILE_PATH`.

```shell
$ bosh delete deployment DEPLOYMENT_NAME [--force]
```

Deletes job instances, VMs, disks, snapshots, templates associated with the deployment `DEPLOYMENT_NAME`.

---
### Job/VM Health {: #health }

```shell
$ bosh instances [--ps] [--details] [--dns] [--vitals]
```

Displays a table that provides an overview of the instances in a current deployment. You can specify the following options:

- **ps**: includes process information
- **details**: includes VM cloud ID, agent ID
- **dns**: includes the DNS A record
- **vitals**: includes load, CPU, memory, swap, system disk, ephemeral disk, and persistent disk usage

```shell
$ bosh vms [DEPLOYMENT_NAME] [--details] [--dns] [--vitals]
```

Displays a table that provides an overview of the VMs in `DEPLOYMENT_NAME`. You can specify the following options:

- **details**: includes VM cloud ID, agent ID
- **dns**: includes the DNS A record
- **vitals**: includes load, CPU, memory, swap, system disk, ephemeral disk, and persistent disk usage

```shell
$ bosh recreate JOB [INDEX] [--force]
```

Stops the job process, recreates the VM, creates the job instance on the new VM, then starts the job process. `--force`
executes the command even if the local manifest doesn't match the version the BOSH director has.

```shell
$ bosh stop JOB [INDEX] [--hard] [--force]
```

Stops the job processes, and if `--hard` is specified deletes a VM keeping persistent disks.

```shell
$ bosh start JOB [INDEX] [--force]
```

Creates a VM and reattaches active persistent disk if VM does not exist, then starts the job processes.

#### Resurrection {: #vm-resurrection }

```shell
$ bosh vm resurrection [STATE]
$ bosh vm resurrection JOB INDEX [STATE]
```

Sets resurrection state (`on` or `off`) for all VMs managed by the Director or for a single deployment job instance.

```shell
$ bosh cck [DEPLOYMENT_NAME] [--auto] [--report]
```

Scans for differences between the VM state database that the Director maintains and the actual state of the VMs. For each difference the scan detects, `bosh cck` offers possible repair options.

---
### Errands {: #errand }

```shell
$ bosh errands
```

Displays a table that lists all available errands for the set deployment.

```shell
$ bosh run errand ERRAND_NAME [--download-logs] [--logs-dir DESTINATION_DIRECTORY]
```

Instructs the BOSH Director to run the named errand on a job instance on a VM.

---
### SSH {: #ssh }

```shell
$ bosh ssh [--gateway_host HOST] [--gateway_user USER] [--gateway_identity_file FILE] [--default_password PASSWORD]
```

Executes a command or starts an interactive shell via SSH. You can tunnel the SSH connection over a `gateway` by specifying additional options.

```shell
$ bosh ssh JOB [INDEX] [COMMANDS]
```

When you provide arguments without an option flag, the Director executes the arguments as commands on the job VM. For example, `bosh ssh redis 0 "ls -R"` runs the `ls -R` command on the redis/0 job VM.

---
### Director Tasks {: #tasks }

```shell
$ bosh tasks [--no-filter]
```

Displays a table that lists the following for all _currently running_ tasks: ID number, state, timestamp, user, description, and result.

```shell
$ bosh tasks recent [COUNT] [--no-filter]
```

Displays a table that lists the following for the last `COUNT` tasks: ID number, state, timestamp, user, description, and result. `COUNT` defaults to 30.

```shell
$ bosh task [TASK_ID] [--event] [--cpi] [--debug] [--result] [--raw]
```

Displays the status of a task that you specify and tracks its output. You can track only one of the following log types at a time: event, CPI, debug, or result. Defaults to event.

---
### Logs {: #logs }

```shell
$ bosh logs JOB [INDEX] [--agent] [--job] [--only filter1,filter2,...] [--dir DESTINATION_DIRECTORY]
```

Fetches a job or agent log from a VM. Supports custom filtering only for job logs.

---
### Events {: #events }

```shell
$ bosh events [--before-id ID] [--deployment NAME] [--task ID] [--instance NAME/ID]
```

Displays table that lists events based on filters specified. See [events details](events.md).

---
### Disks {: #disks }

```shell
$ bosh disks --orphaned
```

Displays disk CID, previous deployment and instance, and orphaned date of all orphaned persistent disks.

```shell
$ bosh attach disk DISK_ID INSTANCE_NAME/ID
```

Attaches persistent disk to given instance. Instance must be in the stopped state.

---
### Snapshots {: #snapshots }

```shell
$ bosh snapshots
```

Displays the job, CID, and created date of all snapshots.

```shell
$ bosh take snapshot [JOB] [INDEX]
```

Takes a snapshot of the job VM that you specify. If you do not specify a `JOB`, takes a snapshot of every VM in your deployment.

```shell
$ bosh delete snapshots
```

Deletes all snapshots.

```shell
$ bosh delete snapshot SNAPSHOT_CID
```

Deletes a snapshot.

---
## For Release Maintainers {: #release-maintainers }

Use these commands against the Director to create and update releases.

### Release Creation {: #main-release }

```shell
$ bosh create release [MANIFEST_FILE] [--name NAME] [--version VERSION] [--with-tarball] [--force]
```

Creates a development release.

```shell
$ bosh create release [MANIFEST_FILE] [--name NAME] [--version VERSION] [--with-tarball] [--force] --final
```

Creates a final release.

```shell
$ bosh finalize release RELEASE_PATH [--name NAME] [--version VERSION]
```

Create a final release from a development release tarball (assumes current directory to be a release directory).

### Blobs {: #blobs }

```shell
$ bosh blobs
```

Lists blobs pending an upload.

```shell
$ bosh upload blobs
```

Uploads new and updated blobs to the blobstore.
