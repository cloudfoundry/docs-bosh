All managed VMs include:

- BOSH Agent
- Monit daemon
- `/var/vcap/` directory

Each BOSH managed VM may be assigned a single copy of a deployment job to run. At that point VM is considered to be an instance of that deployment job -- it has a name and an index (e.g.  `redis-server/0`).

When the assignment is made, the Agent will populate `/var/vcap/jobs` directory with the jobs specified in the instance group definition from the deployment manifest. If the jobs depend on packages, then those will also be downloaded and placed into the `/var/vcap/packages` directory. For example given a following deployment job definition:

```yaml
instance_groups:
- name: redis-master
  jobs:
  - {name: redis-server, release: redis}
  - {name: syslog-forwarder, release: syslog}
  ...
```

Then the Agent will download the two jobs into the following directories:

- `redis-server` into `/var/vcap/jobs/redis-server`
- `syslog-forwarder` into `/var/vcap/jobs/syslog-forwarder`

Assuming that the `redis-server` job depends on a `redis` package and the `syslog-forwarder` job depends on a `syslog-forwarder` package, the Agent will download two release packages into the following directories:

- `redis` into `/var/vcap/packages/redis`
- `syslog-forwarder` into `/var/vcap/packages/syslog-forwarder`
