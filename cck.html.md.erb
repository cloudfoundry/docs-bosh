---
title: Manual repair with Cloud Check
---

<p class="note">Note: Updated for bosh-release v183 (1.3010.0).</p>

BOSH provides the Cloud Check CLI command (a.k.a cck) to repair IaaS resources used by a specific deployment. It is not commonly used while normal operations; however, it becomes essential when some IaaS operations failed and the Director cannot resolve problems without a human decision or when the Resurrector is not enabled.

As mentioned earlier the Resurrector will only try to recover a VM if it is missing from the IaaS or the if the Agent on the VM is not responding to commands. cck tool is similar to the Resurrector in that it also looks for those two conditions; however, instead of automatically trying to resolve these problems, it provides several options to the operator.

In addition to looking for those two types of problems, cck also checks correct attachment and presence of persistent disks for each deployment job instance.

Once the deployment is set via `bosh deployment` command you can simply run `bosh cck`. Here is an example output when no problems are detected:

<pre class="terminal wide">
$ bosh cck

Performing cloud check...

Processing deployment manifest
------------------------------

Director task 622
  Started scanning 1 vms
  Started scanning 1 vms > Checking VM states. Done (00:00:00)
  Started scanning 1 vms > 1 OK, 0 unresponsive, 0 missing, 0 unbound, 0 out of sync. Done (00:00:00)
     Done scanning 1 vms (00:00:00)

  Started scanning 0 persistent disks
  Started scanning 0 persistent disks > Looking for inactive disks. Done (00:00:00)
  Started scanning 0 persistent disks > 0 OK, 0 missing, 0 inactive, 0 mount-info mismatch. Done (00:00:00)
     Done scanning 0 persistent disks (00:00:00)

Task 622 done

Started		2015-01-09 23:29:34 UTC
Finished	2015-01-09 23:29:34 UTC
Duration	00:00:00

Scan is complete, checking if any problems found...
No problems found
</pre>

---
## <a id="problems"></a> Problems

### <a id="missing-vm"></a> VM is missing

Assuming there was a deployment with a VM, somehow that VM was deleted from the IaaS outside of BOSH, here is what cck would report:

<pre class="terminal wide">
$ bosh cck

Performing cloud check...

Processing deployment manifest
------------------------------

Director task 623
  Started scanning 1 vms
  Started scanning 1 vms > Checking VM states. Done (00:00:10)
  Started scanning 1 vms > 0 OK, 0 unresponsive, 1 missing, 0 unbound, 0 out of sync. Done (00:00:00)
     Done scanning 1 vms (00:00:10)

  Started scanning 0 persistent disks
  Started scanning 0 persistent disks > Looking for inactive disks. Done (00:00:00)
  Started scanning 0 persistent disks > 0 OK, 0 missing, 0 inactive, 0 mount-info mismatch. Done (00:00:00)
     Done scanning 0 persistent disks (00:00:00)

Task 623 done

Started		2015-01-09 23:32:45 UTC
Finished	2015-01-09 23:32:56 UTC
Duration	00:00:11

Scan is complete, checking if any problems found...

Found 1 problem

Problem 1 of 1: VM with cloud ID `i-914c046a' missing.
  1. Skip for now
  2. Recreate VM
  3. Delete VM reference
Please choose a resolution [1 - 3]: 3

Below is the list of resolutions you've provided
Please make sure everything is fine and confirm your changes

  1. VM with cloud ID `i-914c046a' missing.
     Delete VM reference

Apply resolutions? (type 'yes' to continue): yes
Applying resolutions...

Director task 624
  Started applying problem resolutions > missing_vm 168: Delete VM reference. Done (00:00:00)

Task 624 done

Started		2015-01-09 23:33:20 UTC
Finished	2015-01-09 23:33:20 UTC
Duration	00:00:00
Cloudcheck is finished
</pre>

cck determined that `i-914c046a` VM was missing. Possible options are:

1. `Skip for now`: the Director will not try to resolve this problem right now

2. `Recreate VM`: the Director will just create new VM, deploy specified releases according to deployed manifest and finally start release jobs

    Note on current behaviour: cck will not wait for all release job processes to start.

3. `Delete VM reference`: the Director will not create new VM in its place. If cck is run again, it will not report that VM is missing since it's not expected to exist. Running `bosh deploy` after cck will backfill missing VMs.

In the above example options 3 was picked and VM reference was deleted.

---
### <a id="not-responsive-vm"></a> VM is not responsive (unresponsive agent)

Assuming there was a deployment with a VM, somehow Agent is no longer responding to the Director. In this situation `bosh vms` will report VM's agent as `unresponsive agent`:

<pre class="terminal wide">
$ bosh vms simple-deployment --details

Deployment `simple-deployment'

Director task 630

Task 630 done

+-----------------+--------------------+---------------+-----+------------+--------------------------------------+--------------+
| Job/index       | State              | Resource Pool | IPs | CID        | Agent ID                             | Resurrection |
+-----------------+--------------------+---------------+-----+------------+--------------------------------------+--------------+
| unknown/unknown | unresponsive agent |               |     | i-1db9ede6 | 59a30081-d63d-4c1b-80be-01fa681d8787 | active       |
+-----------------+--------------------+---------------+-----+------------+--------------------------------------+--------------+

VMs total: 1
</pre>

Also `bosh deploy` will stop at `Binding existing deployment` stage since it is not able to communicate with unresponsive agent:

<pre class="terminal wide">
$ bosh deploy

..snip...

Deploying
---------
Deployment name: `tiny-dummy.yml'
Director name: `micro-idora'
Are you sure you want to deploy? (type 'yes' to continue): yes

Director task 631
  Started preparing deployment
  Started preparing deployment > Binding deployment. Done (00:00:00)
  Started preparing deployment > Binding releases. Done (00:00:00)
  Started preparing deployment > Binding existing deployment. Failed: Timed out sending `get_state' to 59a30081-d63d-4c1b-80be-01fa681d8787 after 45 seconds (00:02:15)

Error 450002: Timed out sending `get_state' to 59a30081-d63d-4c1b-80be-01fa681d8787 after 45 seconds

Task 631 error

For a more detailed error report, run: bosh task 631 --debug
</pre>

<pre class="terminal wide">
$ bosh cck

Performing cloud check...

Processing deployment manifest
------------------------------

Director task 640
  Started scanning 1 vms
  Started scanning 1 vms > Checking VM states. Done (00:00:10)
  Started scanning 1 vms > 0 OK, 1 unresponsive, 0 missing, 0 unbound, 0 out of sync. Done (00:00:00)
     Done scanning 1 vms (00:00:10)

  Started scanning 0 persistent disks
  Started scanning 0 persistent disks > Looking for inactive disks. Done (00:00:00)
  Started scanning 0 persistent disks > 0 OK, 0 missing, 0 inactive, 0 mount-info mismatch. Done (00:00:00)
     Done scanning 0 persistent disks (00:00:00)

Task 640 done

Started   2015-01-09 23:33:45 UTC
Finished  2015-01-09 23:33:55 UTC
Duration  00:00:10

Scan is complete, checking if any problems found...

Found 1 problem

Problem 1 of 1: dummy/0 (i-914c046a) is not responding.
  1. Skip for now
  2. Reboot VM
  3. Recreate VM
  4. Delete VM reference (forceful; may need to manually delete VM from the Cloud to avoid IP conflicts)
Please choose a resolution [1 - 4]: 4

Below is the list of resolutions you've provided
Please make sure everything is fine and confirm your changes

  1. dummy/0 (i-914c046a) is not responding.
     Delete VM reference (forceful; may need to manually delete VM from the Cloud to avoid IP conflicts)

Apply resolutions? (type 'yes' to continue): yes
Applying resolutions...

Director task 641
  Started applying problem resolutions > unresponsive_agent 168: Delete VM reference (...). Done (00:00:05)

Task 641 done

Started   2015-01-09 23:35:20 UTC
Finished  2015-01-09 23:35:25 UTC
Duration  00:00:05
Cloudcheck is finished
</pre>

cck determined that `i-914c046a` VM is unresponsive. Possible options are:

1. `Skip for now`: the Director will not try to resolve this problem right now

2. `Reboot VM`: the Director will power off and then power on existing VM

    Note on current behaviour: cck will not wait for all release job processes to start.

3. `Recreate VM`: the Director will delete existing VM, then create a new VM, deploy specified releases according to deployed manifest and finally start release jobs

    Note on current behaviour: cck will not wait for all release job processes to start.

4. `Delete VM reference`: the Director will not create new VM in its place. If cck is run again, it will not report that VM is unresponsive since it does not exist. Running `bosh deploy` after cck will backfill missing VMs.

In the above example options 4 was picked and VM reference was deleted.

---
### <a id="unattached-persistent-disk"></a> Persistent Disk is not attached

Assuming there was a deployment with a VM, somehow persistent disk got detached.

<pre class="terminal wide">
$ bosh cck

Performing cloud check...

Processing deployment manifest
------------------------------

Director task 656
  Started scanning 1 vms
  Started scanning 1 vms > Checking VM states. Done (00:00:00)
  Started scanning 1 vms > 1 OK, 0 unresponsive, 0 missing, 0 unbound, 0 out of sync. Done (00:00:00)
     Done scanning 1 vms (00:00:00)

  Started scanning 1 persistent disks
  Started scanning 1 persistent disks > Looking for inactive disks. Done (00:00:00)
  Started scanning 1 persistent disks > 0 OK, 0 missing, 0 inactive, 1 mount-info mismatch. Done (00:00:00)
     Done scanning 1 persistent disks (00:00:00)

Task 656 done

Started   2015-01-13 22:04:56 UTC
Finished  2015-01-13 22:04:56 UTC
Duration  00:00:00

Scan is complete, checking if any problems found...

Found 1 problem

Problem 1 of 1: Inconsistent mount information:
Record shows that disk 'vol-549f071f' should be mounted on i-4fcd99b4.
However it is currently :
  Not mounted in any VM.
  1. Skip for now
  2. Reattach disk to instance
  3. Reattach disk and reboot instance
Please choose a resolution [1 - 3]: 2

Below is the list of resolutions you've provided
Please make sure everything is fine and confirm your changes

  1. Inconsistent mount information:
Record shows that disk 'vol-549f071f' should be mounted on i-4fcd99b4.
However it is currently :
  Not mounted in any VM
     Reattach disk to instance

Apply resolutions? (type 'yes' to continue): yes
Applying resolutions...

Director task 657
  Started applying problem resolutions > mount_info_mismatch 23: Reattach disk to instance. Done (00:00:22)

Task 657 done

Started   2015-01-13 22:05:19 UTC
Finished  2015-01-13 22:05:41 UTC
Duration  00:00:22
Cloudcheck is finished
</pre>

cck determined that `vol-549f071f` persistent disk is not attached to `i-4fcd99b4` VM. Possible options are:

1. `Skip for now`: the Director will not try to resolve this problem during

2. `Reattach disk to instance`: the Director will reattach persistent disk to the VM and mount it at its usual location `/var/vcap/store`.

    Note on current behaviour: Release job processes will not be restarted when persistent disk is remounted.

3. `Reattach disk and reboot instance`: the Director will reattach persistent disk to the VM and reboot it so that Agent can safely mount persistent disk before starting any release job processes.

    Note on current behaviour: cck will not wait until VM reboots and restarts all release job processes.

---
### <a id="missing-persistent-disk"></a> Persistent Disk is missing

Assuming there was a deployment with a VM, somehow persistent disk got deleted.

Note: Not all CPIs implement needed functionality to determine if disk is missing. Those CPIs will report missing disk as [Persistent Disk is not attached](#unattached-persistent-disk) problem; however, both reattaching resolutions will fail since persistent disk would not be found.

---
Next: [Automatic repair with Resurrector](resurrector.html)

Previous: [Process monitoring with Monit](vm-monit.html)
