---
title: VM Configuration Locations
---

This topic describes important file system locations, configurations and other settings that are true for all VMs managed by BOSH.

BOSH tries to encourage release authors to follow conventions listed below, so if you find inconsistencies or improper usage please report such problems to appropriate release authors.

---
## <a id="global"></a> Global Configuration

* `/tmp/`: Global temporary directory is limited to 128MB. A well behaved release job that needs scratch space usually sets up its own temporary directory inside ephemeral data directory (e.g. `/var/vcap/data/redis-server/tmp`).

* `vcap` user: Pre-configured user that comes with the stemcells. Release jobs may run processes under that user. Default password is `c1oudc0w`.

* `/etc/logrotate.d/vcap`: Logrotate configuration for `/var/vcap/sys/log/` sub-directories managed by the Agent.

---
## <a id="jobs-and-packages"></a> Release Job and Package Directories

* `/var/vcap/`: VCAP [1] directory contains majority of the configuration settings and associated assets when VM deployment job instance is assigned to the VM.

* `/var/vcap/packages/`: Contains enabled release packages for the assigned deployment job. The Agent is responsible for managing which packages are enabled or disabled on the VM.

* `/var/vcap/jobs/`: Contains evaluated release jobs for the assigned deployment job. The Agent is responsible for managing which jobs are enabled or disabled on the VM.

    - `/var/vcap/jobs/<name>/bin/`: Conventional location for the release job to keep wrapper executables. ctl script(s) invoked by Monit are placed here (e.g. `/var/vcap/jobs/redis-server/bin/ctl`).

    - `/var/vcap/jobs/<name>/config/`: Conventional location for the release job configuration files (e.g. `/var/vcap/jobs/redis-server/config/redis.conf`).

    - `/var/vcap/jobs/<name>/monit`: Final monit file for that release job.

---
## <a id="storage"></a> Storage Directories

* `/var/vcap/data/`: Directory that is used by the release jobs to keep _ephemeral_ data. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/data/redis-server`).

* `/var/vcap/store/`: Directory that is used by the release jobs to keep _persistent_ data. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/store/redis-server`).

* `/var/vcap/sys/run/`: Directory that is used by the release jobs to keep miscellaneous ephemeral data about  currently running processes, for example, pid and lock files. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/sys/run/redis-server`).

* `/var/vcap/sys/log/`: Directory that is used by the release jobs to keep logs. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/sys/log/redis-server`). Files in this directory are log rotated on a specific schedule configure by the Agent.

---
## <a id="agent"></a> Agent Configuration

It's discouraged to modify or rely on the contents of this directory.

* `/var/vcap/bosh/`: Directory used by the Agent to keep its internal state.

* `/var/vcap/bosh/agent.json`: Start up settings for the Agent that describe how to find bootstrap settings, and disable certain Agent functionality.

* `/var/vcap/bosh/settings.json`: Local copy of the bootstrap settings used by the Agent to configure network, system properties for the VM. They are refreshed every time Agent is restarted.

* `/var/vcap/bosh/spec.json`: Deployment job settings used by the Agent to configure release jobs and packages for the VM. This file also includes name and index for the deployment job associated with this VM.

* `/var/vcap/bosh/log/current`: Current Agent log. Agent's logs are logrotated and archives are kept in `/var/vcap/bosh/log/` directory.

* `/var/vcap/bosh/etc/ntpserver`: File with a list of NTP servers configured by the Agent. This file is used by `/var/vcap/bosh/bin/ntpdate` to keep time in sync.

---
## <a id="monit"></a> Monit Configuration

It's discouraged to modify or rely on the contents of this directory.

* `/var/vcap/monit/job`: Directory that keeps current Monit configuration files. The Agent is responsible for updating files in this directory when deployment job is updated.

* `/var/vcap/monit/monit.log`: Monit activity log. Includes information about starts, stops, restarts, etc. of release job processes monitored by Monit.

---
[Back to Table of Contents](index.html#vm-config)

Previous: [Structure of a BOSH VM](vm-struct.html)

[1] VCAP stands for VMware Cloud Application Platform.
