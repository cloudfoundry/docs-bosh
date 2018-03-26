---
title: Index
---

See [Recent Additions and Updates](recent.md).

## Introduction <a id="intro"></a>

* [What is BOSH?](about.md)
    * [What problems does BOSH solve?](problems.md)
        * [Stemcell](stemcell.md)
        * [Release](release.md)
        * [Deployment](deployment.md)
    * Comparison to other tools
* [General architecture](bosh-components.md)
* [Personas](personas.md)
* [Terminology](terminology.md)

---
## Install BOSH <a id="install"></a>

* [Create an environment](init.md)
    * [On Local machine (BOSH Lite)](bosh-lite.md)
    * [On AWS](init-aws.md)
      * [Expose Director on a Public IP](init-external-ip.md)
    * [On Azure](init-azure.md)
    * [On OpenStack](init-openstack.md)
    * [On vSphere](init-vsphere.md)
    * [On vCloud](init-vcloud.md)
    * [On SoftLayer](init-softlayer.md)
    * [On Google Compute Platform](init-google.md)
    * [On RackHD](rackhd-cpi.md)

---
## Deploy software with BOSH <a id="basic-deploy"></a>

* [Deploy workflow](basic-workflow.md)
    * [Update cloud config](update-cloud-config.md)
    * [Build deployment manifest](deployment-basics.md)
    * [Upload stemcells](uploading-stemcells.md)
    * [Upload releases](uploading-releases.md)
    * [Deploy](deploying.md)
    * Run one-off tasks
    * Update deployment

### CLI v2+ <a id="cli-v2"></a>

* [Command reference](cli-v2.md)
    * [`create-env` Dependencies](cli-env-deps.md)
    * [Differences between CLI v2+ vs v1](cli-v2-diff.md)
    * [Global Flags](cli-global-flags.md)
    * [Environments](cli-envs.md)
    * [Operations files](cli-ops-files.md)
    * [Variable Interpolation](cli-int.md)
    * [Tunneling](cli-tunnel.md)

### Running Director <a id="director-config"></a>

* [Troubleshooting](tips.md)
* [Events](events.md)
* [Director tasks](director-tasks.md)
* [Managing releases](managing-releases.md)
* [Managing stemcells](managing-stemcells.md)
* [User management](director-users.md)
    * [UAA Integration](director-users-uaa.md)
    * [UAA Permissions](director-users-uaa-perms.md)
* CredHub Integration
    * [Variable Types](variable-types.md)
* [Backup and restore](director-backup.md)

#### Misc

* [Deploying step-by-step](deploying-step-by-step.md)
* [SSL certificate configuration](director-certs.md)
* [Removal of compilers](remove-dev-tools.md)
* [Access event logging](director-access-events.md)
* [Explicit ARP Flushing](flush-arp.md)
* [Configuring external database](director-configure-db.md)
* [Configuring external blobstore](director-configure-blobstore.md)

### Detailed deployment configuration <a id="deployment-config"></a>

* [Manifest v2 schema](manifest-v2.md)
    * [Links](links.md)
    * [Link properties](links-properties.md)
    * [Manual linking](links-manual.md)
    * [Renaming/migrating instance groups](migrated-from.md)
* [Persistent and orphaned disks](persistent-disks.md)
    * [Customizing persistent disk FS](persistent-disk-fs.md)
* [Configs](configs.md)
  * [Cloud config](cloud-config.md)
      * [AZs](azs.md)
      * [Networks](networks.md)
      * [VM anti-affinity](vm-anti-affinity.md)
  * [Runtime config](runtime-config.md)
      * [Addons](runtime-config.md#addons)
      * [Common addons](addons-common.md)
  * [CPI config](cpi-config.md)
* [Trusted certificates](trusted-certs.md)
* [Native DNS Support](dns.md)

### Detailed CPI configuration & troubleshooting <a id="cpi-config"></a>

* [AWS](aws-cpi.md)
    * [Using IAM instance profiles](aws-iam-instance-profiles.md)
    * [Using instance storage](aws-instance-storage.md)
    * [Creating IAM users](aws-iam-users.md)
* [Azure](azure-cpi.md)
    * [Creating resources](azure-resources.md)
* [OpenStack](openstack-cpi.md)
    * [Using Auto-anti-affinity](openstack-auto-anti-affinity.md)
    * [Using Keystone v2 API](openstack-keystonev2.md)
    * [Using nova-networking](openstack-nova-networking.md)
    * [Extended Registry configuration](openstack-registry.md)
    * [Human-readable VM names](openstack-human-readable-vm-names.md)
    * [Validating self-signed OpenStack endpoints](openstack-self-signed-endpoints.md)
    * [Multi-homed VMs](openstack-multiple-networks.md)
    * [Using Light Stemcells](openstack-light-stemcells.md)
* [vSphere](vsphere-cpi.md)
    * [vSphere HA](vsphere-ha.md)
    * [Migrating from one datastore to another](vsphere-migrate-datastores.md)
    * [Storage DRS and vMotion Support](vsphere-vmotion-support.md)
* [vCloud](vcloud-cpi.md)
* [SoftLayer](softlayer-cpi.md)
* [Google Compute Engine](google-cpi.md)
    * [Required service account permissions](google-required-permissions.md)
* [RackHD](rackhd-cpi.md)
* [Warden/Garden](warden-cpi.md)
* [VirtualBox](virtualbox-cpi.md)

### Health management of VMs and processes <a id="hm"></a>

* [Monitoring](monitoring.md)
    * [Configuring Health Monitor](hm-config.md)
* [Process monitoring with Monit](vm-monit.md)
* [Manual repair with Cloud Check](cck.md)
* [Automatic repair with Resurrector](resurrector.md)
* [Persistent disk snapshotting](snapshots.md)

### VM configuration (looking inside a deployment) <a id="vm-config"></a>

* [Structure of a managed VM](vm-struct.md)
    * [VM configuration locations](vm-config.md)
* [Location and use of logs](job-logs.md)
* [Instance metadata](instance-metadata.md)
* Debugging issues with jobs

---
## Guides <a id="guides"></a>

* [IPv6 on vSphere](guide-ipv6-on-vsphere.md)
* Multi-CPI
  * [On AWS](guide-multi-cpi-aws.md)

---
## Package software with BOSH <a id="release"></a>

* What is a release?
    * [Creating a release](create-release.md)
    * Testing with dev releases
    * Cutting final releases
    * [Compiled releases](compiled-releases.md)
* [What is a job?](jobs.md)
    * Creating a job
        * [Job Templates](job-templates.md)
    * [Errands](errands.md)
    * [Properties: Suggested configurations](props-common.md)
    * [Links: Common types](links-common-types.md)
    * [Job lifecycle](job-lifecycle.md)
        * [Pre-start script](pre-start.md)
        * [Post-start script](post-start.md)
        * [Post-deploy script](post-deploy.md)
        * [Drain script](drain.md)
    * [Scheduled processes](scheduled-procs.md)
* [Releases and Jobs in Windows](windows.md)
    * [Releases](windows.md#releases)
    * [Jobs](windows.md#jobs)
    * [Sample BOSH Windows Release](windows-sample-release.md)
* What is a package?
    * [Creating a package](packages.md)
    * Relationship to release blobs
    * [Vendoring packages](package-vendoring.md)
    * [Release blobs](release-blobs.md)
* How do releases, jobs, and packages interact?
* Managing release repository
    * [Release blobstore](release-blobstore.md)
        * [Configuring S3 release blobstore](s3-release-blobstore.md)

---
## Extend BOSH <a id="extend"></a>

* [Director API v1](director-api-v1.md)
* What is a CPI?
* [Building a CPI](build-cpi.md)
    * [CPI API v1](cpi-api-v1.md)
    * [Agent-CPI interactions](agent-cpi-interactions.html)
* [Building a stemcell](build-stemcell.md)
    * [Repacking Stemcells](repack-stemcell.md)

---
## Other <a id="other"></a>

### CLI v1 (superseded by [CLI v2](#cli-v2)) <a id="cli-v1"></a>

* [Install BOSH CLI v1](bosh-cli.md)
* [CLI v1](sysadmin-commands.md)

### Manifest v1 <a id="manifest-v1"></a>

* [Manifest v1 schema](deployment-manifest.md)
