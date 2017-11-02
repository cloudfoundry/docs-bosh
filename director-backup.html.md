---
title: How to backup and restore a bosh director deployment?
---

## <a id="why-backup"></a>Why performing bosh director backup and restores ? ##

If using bosh-init to deploy your bosh-director, it is useful to backup the deployment state file containing associated Iaas information (IP, floating IP, persistent disk volume id). This would enable recovery of a lost bosh director VM from the persistent disk still present in the Iaas. See [bosh-init](using-bosh-init.html#recover-deployment-state).

Performing regular backup of the bosh director is essential to be able to operate your bosh deployments (CF, services ...) up despite a loss the the bosh director persistent disk, or an operator error such as the deletion by mistake of the director deployment. See related testimony of such [not fun experience]( https://youtu.be/ZQvxfL3Wb7s?list=PLhuMOCWn4P9io8gtd6JSlI9--q7Gw3epW&t=1307)

Bosh provides built-in commands to export the content of the director database and restore it on a fresh empty director deployment. The back up however does not include the data than can be recovered from artifact repositories, namely bosh stemcells and releases. The latter need to be re uploaded manually.

## <a id="backup-your-bosh"></a>Backup your bosh director ##

Target the bosh director deployment that you need to backup:

`bosh deployment your_bosh_director_manifest`

Make a backup of your bosh instance :

`bosh backup`

This command will generate a .tar.gz file that contains a dump of director's database

## <a id="restore-backup"></a> Restore the backup following an outage ##

We assume that your bosh director deployment was deleted so you need to restore it.

The first step is to deploy a new fresh empty bosh director deployment.

The second step is to restore the content of the bosh director db

* Connect to your bosh instance (using `bosh target https://your_bosh_ip`).
* Use the bosh restore command : `bosh restore yourBackupFile.tar.gz`

The third step is to manually re-upload the releases and stemcells binaries.

* List the expected stemcells and releases

 `bosh stemcells`
 `bosh releases`

Then upload stemcells/releases from your repositories such as bosh.io, using the `--fix` option so bosh will fix them in the db (fixing the missing blobs). Without the `--fix` option, bosh would complain about duplicate stemcells/releases with same name.

 `bosh upload stemcell https://stemcells_url --fix`
 `bosh upload releases https://release_url --fix`

Following these restoration steps, the bosh director is now able to manage your previous deployments.

`bosh cloudcheck`

`bosh instances --ps`

You can now safely update your deployments using the usual deploy command.

`bosh deploy`
