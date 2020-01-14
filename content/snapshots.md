!!! note
    This feature is experimental.

A disk snapshot is a shallow or full copy of a persistent disk at the time of the snapshot creation. Disk snapshotting is implemented with the help of CPIs which use the IaaS snapshot functionality to efficiently make copies of disks.

Take a disk snapshot of a persistent disk before deploying major updates or for other important events. If the changes corrupt persistent disk, promote a disk snapshot to be a persistent disk and attach it to the VM to restore data prior to your changes. Currently BOSH does not provide a CLI command to recover from a snapshot so you must use the recovery features of your IaaS with the [snapshot Content IDs (CIDs)](#manual) to recover the snapshots.

!!! note
    While snapshots allow you to recover disk to a prior state, snapshots are not backups. Taking a snapshot does not necessarily create a complete copy of the original disk. If the original  disk is deleted, your IaaS may invalidate any snapshot files.

## Enabling Snapshots {: #enable }

Since the IaaS might or might not provide snapshotting functionality, disk snapshots are disabled by default. If your IaaS supports snapshots, you must first enable snapshots in your IaaS and then in the Director.

To enable disk snapshots in the Director:

1. Add an `enable_snapshots` [key](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh&version=270.10.0#p%3ddirector.enable_snapshots) with it's value set to `true` to the `director` block of your Director deployment manifest.

    ```yaml
    properties:
      director:
        enable_snapshots: true
    ```

1. Run `bosh create-env manifest.yml` to update your Director deployment (see `create-env`[command](https://bosh.io/docs/cli-v2/#create-env) for details).

## Manual Snapshots {: #manual }

Once you enable snapshots in your deployment, you can use following CLI commands to take snapshots on demand.

!!! note
    When you manually take a snapshot, the Director does not pause any processes or flush buffered data to disk. Depending on your IaaS, a snapshot taken manually might not fully capture all the data on your VM at the point you take the snapshot.

```shell
bosh snapshots
```

Displays the job, Content ID (CID), and created date of all snapshots. Run <code>bosh snapshots</code> to display a list of CIDs if you need to find specific snapshots to recover.

```shell
bosh take snapshot [JOB] [INDEX]
```

Takes a snapshot of the job VM that you specify. If you do not specify a <code>JOB</code>, takes a snapshot of every VM in the current deployment.

```shell
bosh delete snapshot SNAPSHOT-CID
```

Deletes the snapshot that SNAPSHOT-CID specifies.

```shell
bosh delete snapshots
```

Deletes all snapshots.

## Job Update Snapshots {: #automatic }

Once you enable snapshots in the Director, the Director automatically takes a snapshot of the persistent disk whenever an event triggers a deployment job update. Before taking the snapshot, the Director waits for release job processes to stop (and/or drain).

## Scheduled Snapshots {: #automatic }

The Director can take snapshot of persistent disks at regular intervals for all VMs in all deployments and/or the VM the Director is running on.

!!! note
    When the Director starts a scheduled snapshot, it does not pause any processes or flush       buffered data to disk. Depending on your IaaS, a scheduled snapshot might not fully capture       all the data on your VM at the point you take the snapshot.

To schedule snapshots for all VMs in all deployments:

1. Add a `snapshot_schedule` [key](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh&version=270.10.0#p%3ddirector.snapshot_schedule) to the `director` block of your Director deployment manifest.

1. Add a [cron-formatted](https://github.com/jmettraux/rufus-scheduler/blob/two/README.rdoc#a-note-about-cron-jobs) schedule as a value for the `snapshot_schedule` key.

  	```yaml
    properties:
      director:
        enable_snapshots: true
        snapshot_schedule: 0 0 7 * * * UTC
    ```

1. Run `bosh create-env manifest.yml` to update your Director deployment (see `create-env`[command](https://bosh.io/docs/cli-v2/#create-env) for details).

To schedule snapshots for the Director VM:

1. Add a `self_snapshot_schedule` [key](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh&version=270.10.0#p%3ddirector.self_snapshot_schedule) to the `director` block of your Director deployment manifest.

1. Add a cron-formatted schedule as a value for the `self_snapshot_schedule` key.

    ```yaml
    properties:
      director:
        enable_snapshots: true
        self_snapshot_schedule: 0 0 6 * * * UTC
    ```

1. Run `bosh create-env manifest.yml` to update your Director deployment (see `create-env`[command](https://bosh.io/docs/cli-v2/#create-env) for details).
