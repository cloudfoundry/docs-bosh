This document lists several common problems. If you are looking for CPI specific errors see:

- [AWS CPI errors](aws-cpi-errors.md)
- [Azure CPI errors](azure-cpi-errors.md)
- [OpenStack CPI errors](openstack-cpi-errors.md)
- [vSphere CPI errors](vsphere-cpi-errors.md)

---
## Timed out pinging to ... after 600 seconds {: #unreachable-agent }

```shell
$ bosh deploy
...

  Failed creating bound missing vms > cloud_controller_worker/0: Timed out pinging to 013ce5c9-e7fc-4f1d-ac24 after 600 seconds (00:16:03)
  Failed creating bound missing vms > uaa/0: Timed out pinging to b029652d-14c3-4d68-98c7 after 600 seconds (00:16:12)
  Failed creating bound missing vms > uaa/0: Timed out pinging to 1f56ddd1-7f2d-4afc-ae43 after 600 seconds (00:16:23)
  Failed creating bound missing vms > loggregator_trafficcontroller/0: Timed out pinging to 28790bac-99a2-4703-89ad after 600 seconds (00:16:25)
  Failed creating bound missing vms > health_manager/0: Timed out pinging to 720b805b-928c-4bb7-b6dd after 600 seconds (00:16:52)
  Failed creating bound missing vms (00:16:53)

Error 450002: Timed out pinging to 013ce5c9-e7fc-4f1d-ac24 after 600 seconds

Task 45 error

For a more detailed error report, run: bosh task 45 --debug
```

This problem can occur due to:

- blocked network connectivity between the Agent on a new VM and NATS (typically the Director VM)
- bootstrapping problem on the VM and/or wrong configuration of the Agent
- blocked or slow boot times of the VM

It's recommended to start a deploy again and SSH into one of the VMs and look at [the Agent logs](job-logs.md#agent-logs) while the Director waits for VMs to become accessible. See [`director.debug.keep_unreachable_vms` property](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.debug.keep_unreachable_vms) to let Director know to leave unreachable VMs for easier debugging.

## Timed out sending 'get_task' to instance: 'unknown' ...

```shell
$ bosh deploy
...

Updating instance clock_global: clock_global/b0d76aa7-9a4e-44f6-8e28-72d941dc0e16 (0) (canary) (00:06:15)
  L Error: Timed out sending 'get_task' to instance: 'unknown', agent-id: 'f66bf7ce-bd5e-4528-937a-a25ba8223508' after 45 seconds
Error: Timed out sending 'get_task' to instance: 'unknown', agent-id: 'f66bf7ce-bd5e-4528-937a-a25ba8223508' after 45 seconds
```

In case when the VM spec has not been applied, the instance name is not available yet and the timeout error message will display that the instance name as 'unknown'. This also holds for other actions beyond `get_task`, such as `get_state`, `cancel_task`, `apply`, etc...

The steps for remediation are similar to the [Timed out pinging to ... after 600 seconds](#unreachable-agent) case, where operators should try to SSH into VMs as the problem is occurring so they can look at the Agent logs.

---
## ...is not running after update {: #failed-job }

```shell
$ bosh deploy
...

  Started updating job access_z1 > access_z1/0 (canary)
     Done updating job route_emitter_z1 > route_emitter_z1/0 (canary) (00:00:13)
     Done updating job cc_bridge_z1 > cc_bridge_z1/0 (canary) (00:00:20)
     Done updating job cell_z1 > cell_z1/0 (canary) (00:00:40)
   Failed updating job access_z1 > access_z1/0 (canary): `access_z1/0' is not running after update (00:02:13)

Error 400007: `access_z1/0' is not running after update

Task 47 error

For a more detailed error report, run: bosh task 47 --debug
```

This problem occurs when one of the release jobs on a VM did not successfully start in a given amount of time. You can use [`bosh instances --ps`](sysadmin-commands.md#health) command to find out which process on the VM is failing. You can also [access logs](job-logs.md#vm-logs) to view additional information.

This problem may also arise when deployment manifest specifies too small of a [canary/update watch time](deployment-manifest.md#update) which may not be large enough for a process to successfully start.

---
## umount: /var/vcap/store: device is busy {: #unmount-persistent-disk }

```shell
L Error: Action Failed get_task: Task 5be893c6-7a2c-4f3f-420b-433fd23528a1 result: Migrating persistent disk: Remounting persistent disk as readonly: Unmounting /var/vcap/store: Running command: 'umount /var/vcap/store', stdout: '', stderr: 'umount: /var/vcap/store: device is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
': exit status 1
```

This process occurs when one of the processes (from one of the installed jobs) did not fully shutdown and continues to retain a reference to the persistent disk. Agent tries to unmount persistent disk and unmount command fails. You can use `bosh ssh` command to get inside the VM and diagnose which process is holding onto the persistent disk via `lsof | grep /var/vcap/store` (ran as root).

---
## Running command: bosh-blobstore-dav -c ... 500 Internal Server Error {: #blobstore-out-of-space }

```shell
$ bosh deploy
...

Failed compiling packages > dea_next/3e95ef8425be45468e044c05cc9aa65494281ab5: Action Failed get_task: Task bd35f7c1-2144-4045-763e-40beeafc9fa3 result: Compiling package dea_next: Uploading compiled package: Creating blob in inner blobstore: Making put command: Shelling out to bosh-blobstore-dav cli: Running command: 'bosh-blobstore-dav -c /var/vcap/bosh/etc/blobstore-dav.json put /var/vcap/data/tmp/bosh-platform-disk-TarballCompressor-CompressFilesInDir949066221 cd91a1c5-a034-4c69-4608-6b18cc3fcb2b', stdout: 'Error running app - Putting dav blob cd91a1c5-a034-4c69-4608-6b18cc3fcb2b: Wrong response code: 500; body: <html>
<head><title>500 Internal Server Error</title></head>
<body bgcolor="white">
<center><h1>500 Internal Server Error</h1></center>
<hr><center>nginx</center>
</body>
</html>
', stderr: '': exit status 1 (00:03:16)
```

This problem can occur if the Director is configured to use built-in blobstore and does not have enough space on its persistent disk. You can redeploy the Director with a larger persistent disk. Alternatively you can remove unused releases by running `bosh clean-up` command.

If `bosh clean-up` command fails with 500 Internal Server Error, consider removing `/var/vcap/store/director/tasks` to free up a little bit of persistent disk space before running `bosh clean-up` command again. (Deleting that directory will delete Director task debug logs.)

---
## Debugging Director database {: #director-db }

Rarely it's necessary to dive into the Director DB. The easiest way to do so is to SSH into the Director VM and use `director_ctl console`. For example:

```shell
$ ssh vcap@DIRECTOR-IP

$ /var/vcap/jobs/director/bin/director_ctl console
=> Loading /var/vcap/jobs/director/config/director.yml
=> ruby-debug not found, debugger disabled
=> Welcome to BOSH Director console
=> You can use 'app' to access REST API
=> You can also use 'cloud', 'blobstore', 'nats' helpers to query these services
irb(main):001:0> Bosh::Director::Models::RenderedTemplatesArchive.count
=> 3
```

!!! note
    It's not recommended to modify the Director database via this or other manual methods. Please let us know via GitHub issue if you need a certain feature in the BOSH CLI to do some operation.

---
## Task X cancelled {: #canceled-task }

```shell
$ bosh deploy
...

  Started preparing package compilation > Finding packages to compile. Done (00:00:01)
  Started preparing dns > Binding DNS. Done (00:00:05)

Error 10001: Task 106 cancelled

Task 106 cancelled
```

This problem typically occurs if the Director's system time is out of sync, or if the Director machine is underpowered.

---
## Upload release fails {: #upload-release-entity-too-large }

```shell
$ bosh upload release blah.tgz
...
  Started creating new packages > blah_package/f9098f452f46fb072a6000b772166f349ffe27da. Failed: Could not create object, 413/<html>
<head><title>413 Request Entity Too Large</title></head>
<body bgcolor="white">
<center><h1>413 Request Entity Too Large</h1></center>
<hr><center>nginx</center>
</body>
</html>
 (00:02:10)

Error 100: Could not create object, 413/<html>
<head><title>413 Request Entity Too Large</title></head>
<body bgcolor="white">
<center><h1>413 Request Entity Too Large</h1></center>
<hr><center>nginx</center>
</body>
</html>
...
```

This failure occurs due to nginx configuration problems with the director and the nginx blobstore. This can be remedied by configuring the `max_upload_size` property on the director and blobstore jobs.

---
## Persistent Disk with id <UUID> not found {: #persistent-disk-not-found }

```shell
$ bosh create-env
(...)
Command 'deploy' failed:
  Deploying:
    Creating instance 'bosh/0':
      Updating instance disks:
        Updating disks:
          Deploying disk:
            Mounting disk:
              Sending 'get_task' to the agent:
                Agent responded with error: Action Failed get_task: Task 7e4d289d-b97c-4464-40d4-ecc90cc2a94b result: Persistent disk with volume id '14128b61-e046-48ae-b48a-fc0324716b83' could not be found
```

The SSH tunnel between your machine and the VM in the cloud can be terminated prematurly, see [corresponding bug](https://github.com/cloudfoundry/bosh-cli/issues/110). Update CLI v2 to version >= v2.0.2 to fix this.
