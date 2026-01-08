This topic describes important file system locations, configurations and other settings that are true for all the VMs managed by Bosh, also called the “Bosh instances”.

BOSH tries to encourage release authors to follow the conventions listed below, so if you find inconsistencies or improper usage please report such problems to appropriate release authors.

---
## Global Configuration {: #global }

* `/tmp/`: Global temporary directory is limited to 128MB. A well behaved release job that needs scratch space usually sets up its own temporary directory inside ephemeral data directory (e.g. `/var/vcap/data/redis-server/tmp`).

* `vcap` user: Pre-configured user that comes with the stemcells. Release jobs may run processes under that user. The default password will be random.

!!! Note
    BPM enforces that convention and runs processes with the `vcap` user by
    default. Release authors should not run processes as `root` user, but
    instead use the `capabilities` array, in BPM configuration. See the
    [process Schema](https://bosh.io/docs/bpm/config/#process-schema) section
    for more details.

* `/etc/logrotate.d/vcap`: Logrotate configuration for `/var/vcap/sys/log/` sub-directories. See the [“Log rotation” section](job-logs.md#log-rotation)     for more details on rotation of log files.

    The contract with release authors, for the log files produced by jobs, is
    the following:

    1. Log files _SHOULD_ be place inside the `/var/vcap/sys/log/<job-name>/`
       directory.
    2. Log files _MAY_ be placed one level deeper in a
       `/var/vcap/sys/log/<job-name>/<process-name>/` directory, this is
       supported.
    3. Log files _MAY_ be placed directly in `/var/vcap/sys/log/` but it's
       discouraged to do so.
    4. Log files _MUST NOT_ be placed anywhere else that these locations.
    5. Filenames for log files _MUST_ end with `.log`.
    6. Filenames _MAY_ start with a dot (`.`) if release authors are forced to do
       so, but it's not recommended.

---
## Release Job and Package Directories {: #jobs-and-packages }

* `/var/vcap/`: VCAP<sup>[1]</sup> directory contains majority of the configuration settings and associated assets for the Bosh instance.

* `/var/vcap/packages/`: Contains enabled release packages for the instance. The Agent is responsible for managing which packages are enabled or disabled on the VM.

* `/var/vcap/jobs/`: Contains evaluated release jobs for the instance. The Agent is responsible for managing which jobs are enabled or disabled on the VM.

    - `/var/vcap/jobs/<job-name>/bin/`: Conventional location where Bosh renders the templates for wrapper scripts and [hook scripts](job-lifecycle.md).

    - `/var/vcap/jobs/<job-name>/config/`: Conventional location for the job configuration files, like BPM config (in `/var/vcap/jobs/redis-server/config/bpm.yml`, responsible for starting executables). and other rendered config files (e.g. `/var/vcap/jobs/redis-server/config/redis.conf`).

    - `/var/vcap/jobs/<job-name>/monit`: The rendered monit file for that release job. (All such files are then gathered by the Bosh Agent in `/var/vcap/monit/job`, where the actual monit configuration relies, see below.)

---
## Storage Directories {: #storage }

* `/var/vcap/data/`: Directory that is used by the release jobs to keep _ephemeral_ data. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/data/redis-server`).

* `/var/vcap/store/`: Directory that is used by the release jobs to keep _persistent_ data. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/store/redis-server`).

* `/var/vcap/sys/run/`: Directory that is used by the release jobs to keep miscellaneous ephemeral data about  currently running processes, for example, pid and lock files. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/sys/run/redis-server`).

* `/var/vcap/sys/log/`: Directory that is used by the release jobs to keep logs. Each release job usually creates a sub-folder with its name for namespacing (e.g. `redis-server` will place data into `/var/vcap/sys/log/redis-server`). Files in this directory are log rotated on a specific schedule configure by the Agent.

---
## Agent Configuration {: #agent }

It's discouraged to modify or rely on the contents of this directory.

* `/var/vcap/bosh/`: Directory used by the Agent to keep its internal state.

* `/var/vcap/bosh/agent.json`: Start up settings for the Agent that describe how to find bootstrap settings, and disable certain Agent functionality.

* `/var/vcap/bosh/settings.json`: Local copy of the bootstrap settings used by the Agent to configure network, system properties for the VM. They are refreshed every time Agent is restarted.

* `/var/vcap/bosh/update_settings.json`: The updated settings, as pushed by
  the last `update_settings` RPC message sent through NATS to the Bosh Agent.
  These settings may differ from the bootstrap `settings.json`, especially
  with NATS client certificates, that are short-lived at bootstrap, and then
  replaced by the definitive client certificates, using `update_settings`.

* `/var/vcap/bosh/spec.json`: Instance settings used by the Agent to configure release jobs and packages for the VM. This file also includes structural info about the instance, like the deployment name (`deployment`), the instance group (`name`), the human-friendly instance ordinal (`index`), and the immutable instance UUID (`id`). These structural info are also put in the `/var/vcap/instance` directory for easier access, see [Instance Metadata on Filesystem](instance-metadata.md#fs) for more details.

* `/var/vcap/bosh/log/current`: Current Agent log. Agent's logs are logrotated and archives are kept in `/var/vcap/bosh/log/` directory.

* `/var/vcap/bosh/etc/ntpserver`: File with a list of NTP servers configured by the Agent. This file is used by `/var/vcap/bosh/bin/ntpdate` to keep time in sync.

---
## Monit Configuration {: #monit }

It's discouraged to modify or rely on the contents of this directory.

* `/var/vcap/monit/job`: Directory that keeps current Monit configuration files. The Agent is responsible for updating files in this directory when deployment job is updated.

* `/var/vcap/monit/monit.log`: Monit activity log. Includes information about starts, stops, restarts, etc. of release job processes monitored by Monit.

<sup>[1]</sup> “VCAP” stands for “VMware Cloud Application Platform”.
