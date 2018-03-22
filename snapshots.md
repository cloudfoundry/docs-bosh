---
title: Persistent disk snapshotting
---

<p class="note"><strong>Note</strong>: This feature is experimental.</p>

A disk snapshot is a shallow or full copy of a persistent disk at the time of the snapshot creation. Disk snapshotting is implemented with the help of CPIs which use the IaaS snapshot functionality to efficiently make copies of disks.

Take a disk snapshot of a persistent disk before deploying major updates or for other important events. If the changes corrupt persistent disk, promote a disk snapshot to be a persistent disk and attach it to the VM to restore data prior to your changes. Currently BOSH does not provide a CLI command to recover from a snapshot so you must use the recovery features of your IaaS with the [snapshot Content IDs (CIDs)](#manual) to recover the snapshots.

<p class="note"><strong>Note</strong>: While snapshots allow you to recover disk to a prior state, snapshots are not backups. Taking a snapshot does not necessarily create a complete copy of the original disk. If the original disk is deleted, your IaaS may invalidate any snapshot files.</p>

## <a id='enable'></a> Enabling Snapshots

Since the IaaS might or might not provide snapshotting functionality, disk snapshots are disabled by default. If your IaaS supports snapshots, you must enable snapshots in your IaaS and in the Director to use disk snapshots.

To enable disk snapshots:

1. Change the deployment manifest for the Director:

    ```yaml
    properties:
      director:
        enable_snapshots: true
    ```

1. Run `bosh deploy` to update your deployment.

## <a id='manual'></a> Manual Snapshots

Once you enable snapshots in your deployment, you can use following CLI commands to take snapshots on demand.

<p class="note"><strong>Note</strong>: When you manually take a snapshot, the Director does not pause any processes or flush buffered data to disk. Depending on your IaaS, a snapshot taken manually might not fully capture all the data on your VM at the point you take the snapshot.</p>

<pre class="terminal">
$ bosh snapshots
</pre>

Displays the job, Content ID (CID), and created date of all snapshots. Run <code>bosh snapshots</code> to display a list of CIDs if you need to find specific snapshots to recover.

<pre class="terminal">
$ bosh take snapshot [JOB] [INDEX]
</pre>

Takes a snapshot of the job VM that you specify. If you do not specify a <code>JOB</code>, takes a snapshot of every VM in the current deployment.

<pre class="terminal">
$ bosh delete snapshot SNAPSHOT-CID
</pre>

Deletes the snapshot that SNAPSHOT-CID specifies.

<pre class="terminal">
$ bosh delete snapshots
</pre>

Deletes all snapshots.

## <a id='automatic'></a> Job Update Snapshots

Once you enable snapshots in the Director, the Director automatically takes a snapshot of the persistent disk whenever an event triggers a deployment job update. Before taking the snapshot, the Director waits for release job processes to stop (and/or drain).

## <a id='automatic'></a> Scheduled Snapshots

The Director can take snapshot of a persistent disk at regular intervals for all VMs in all deployments and the VM the Director is running on.

<p class="note"><strong>Note</strong>: When the Director starts a scheduled snapshot, it does not pause any processes or flush buffered data to disk. Depending on your IaaS, a scheduled snapshot might not fully capture all the data on your VM at the point you take the snapshot.</p>

To schedule snapshots for all VMs in all deployments:

1. Add a `snapshot_schedule` key to the `director` block of your deployment manifest.

1. Add a [cron-formatted](https://github.com/jmettraux/rufus-scheduler/blob/two/README.rdoc#a-note-about-cron-jobs) schedule as a value for the `snapshot_schedule` key.

  	```yaml
    properties:
      director:
        enable_snapshots: true
        snapshot_schedule: 0 0 7 * * * UTC
    ```

1. Run `bosh deploy` to update your deployment.

To schedule snapshots for the Director VM:

1. Add a `self_snapshot_schedule` key to the `director` block of your deployment manifest.

1. Add a cron-formatted schedule as a value for the `self_snapshot_schedule` key.

    ```yaml
    properties:
      director:
        enable_snapshots: true
        self_snapshot_schedule: 0 0 6 * * * UTC
    ```

1. Run `bosh deploy` to update your deployment.

---
[Back to Table of Contents](index.html#hm)

Previous: [Automatic repair with Resurrector](resurrector.html)
