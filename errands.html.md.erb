---
title: Errands
---

(See [Jobs](jobs.html) for an introduction to jobs.)

Any job that includes `bin/run` script in its spec file's templates section is considered to be an errand. Operator can trigger execution of an errand at any time after the deploy and receive back script's stdout, stderr and exit code upon its completion.

---
## <a id="release-definition"></a> Release Definition

Example of an errand job `smoke-tests` from Zookeeper release. `bin/run` script is specified in its templates section:

```yaml
---
name: smoke-tests

templates:
  run.sh: bin/run

consumes:
- name: conn
  type: zookeeper
  properties:
  - client_port

packages:
- smoke-tests

properties: {}
```

with a `run.sh` template:

```bash
#!/bin/bash
set -e
<%% conn = link('conn') %%>
export ZOOKEEPER_SERVERS=<%%= conn.instances.map { |i| "#{i.address}:#{conn.p('client_port')}" }.join(",") %%>
/var/vcap/packages/smoke-tests/bin/tests
```

---
## <a id="include-in-deployment"></a> Include in a Deployment

There are two ways to add an errand to a deployment:

- add it to a dedicated instance group
- add it to an existing instance group (colocated) (available in bosh-release v263+)

In some cases it makes sense to place an errand in a dedicated instance group. You can add an instance group that specifies only an errand job in its jobs section:

```yaml
- name: smoke-tests
  azs: [z1]
  lifecycle: errand
  instances: 1
  jobs:
  - name: smoke-tests
    release: zookeeper
    properties: {}
  vm_type: default
  stemcell: default
  networks:
  - name: default
```

Note that above example uses `lifecycle: errand` configuration to specify that `smoke-tests` instances should only be present when the `smoke-tests` errand is running. Cloud compute resources will be allocated right before errand is running and released when errand is finished.

Alternatively, it might make sense to colocate an errand job with other jobs in an existing instance group. This might be useful if an errand is meant to perform work local to an instance or simply to avoid adding additional resources to your deployment:

```yaml
- name: zookeeper
  azs: [z1, z2, z3]
  instances: 1
  jobs:
  - name: zookeeper
    release: zookeeper
    properties: {}
  - name: status
    release: zookeeper
    properties: {}
  vm_type: default
  persistent_disk: 10240
  stemcell: default
  networks:
  - name: default
```

---
## <a id="execution"></a> Execution

Unlike regular jobs which run continiously and get automatically restarted on failure, errand jobs are executed upon operator's request some time after a deploy and if fail do not get restarted. There is no timeout on how long an errand can execute.

Note that currently Director will acquire deployment lock for chosen deployment which will prevent execution of other commands that also require deployment lock (for example `bosh deploy` or another errand execution). This behaviour will be made more granular over time allowing more commands to run in parallel against a single deployment.

After running [`bosh deploy` command](cli-v2.html#deploy) to update your deployment, you can inspect which errands are available within a deployment via [`bosh errands` command](cli-v2.html#errands):

<pre class="terminal">
$ bosh -e vbox -d zookeeper errands
Using environment '192.168.56.6' as client 'admin'

Using deployment 'zookeeper'

Name
smoke-tests
status

2 errands

Succeeded
</pre>

To execute an errand, use [`bosh run-errand` command](cli-v2.html#run-errand).

<pre class="terminal wide">
$ bosh -e vbox -d zookeeper run-errand status
Using environment '192.168.56.6' as client 'admin'

Using deployment 'zookeeper'

Task 5609

Task 5609 | 01:31:57 | Preparing deployment: Preparing deployment (00:00:01)
Task 5609 | 01:31:58 | Running errand: zookeeper/0015b995-5ec3-4519-8c11-6521b0aa079d (3)
Task 5609 | 01:31:58 | Running errand: zookeeper/e31944b9-8bf5-4a42-8d6b-3402a85d24d8 (0)
Task 5609 | 01:31:58 | Running errand: zookeeper/3e977542-d53e-4630-bc40-72011f853cb5 (4)
Task 5609 | 01:31:58 | Running errand: zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc (1)
Task 5609 | 01:31:58 | Running errand: zookeeper/d9e00366-8ab1-4ea2-bae3-14cd6bf562cd (2)
Task 5609 | 01:31:59 | Running errand: zookeeper/0015b995-5ec3-4519-8c11-6521b0aa079d (3) (00:00:01)
Task 5609 | 01:31:59 | Fetching logs for zookeeper/0015b995-5ec3-4519-8c11-6521b0aa079d (3): Finding and packing log files
Task 5609 | 01:31:59 | Running errand: zookeeper/e31944b9-8bf5-4a42-8d6b-3402a85d24d8 (0) (00:00:01)
Task 5609 | 01:31:59 | Fetching logs for zookeeper/e31944b9-8bf5-4a42-8d6b-3402a85d24d8 (0): Finding and packing log files
Task 5609 | 01:31:59 | Running errand: zookeeper/d9e00366-8ab1-4ea2-bae3-14cd6bf562cd (2) (00:00:01)
Task 5609 | 01:31:59 | Fetching logs for zookeeper/d9e00366-8ab1-4ea2-bae3-14cd6bf562cd (2): Finding and packing log files
Task 5609 | 01:32:00 | Fetching logs for zookeeper/0015b995-5ec3-4519-8c11-6521b0aa079d (3): Finding and packing log files (00:00:01)
Task 5609 | 01:32:00 | Running errand: zookeeper/3e977542-d53e-4630-bc40-72011f853cb5 (4) (00:00:02)
Task 5609 | 01:32:00 | Running errand: zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc (1) (00:00:02)
Task 5609 | 01:32:00 | Fetching logs for zookeeper/e31944b9-8bf5-4a42-8d6b-3402a85d24d8 (0): Finding and packing log files (00:00:01)
Task 5609 | 01:32:00 | Fetching logs for zookeeper/d9e00366-8ab1-4ea2-bae3-14cd6bf562cd (2): Finding and packing log files (00:00:01)
Task 5609 | 01:32:00 | Fetching logs for zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc (1): Finding and packing log files
Task 5609 | 01:32:00 | Fetching logs for zookeeper/3e977542-d53e-4630-bc40-72011f853cb5 (4): Finding and packing log files
Task 5609 | 01:32:01 | Fetching logs for zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc (1): Finding and packing log files (00:00:01)
Task 5609 | 01:32:01 | Fetching logs for zookeeper/3e977542-d53e-4630-bc40-72011f853cb5 (4): Finding and packing log files (00:00:01)

Task 5609 Started  Mon Sep 18 01:31:57 UTC 2017
Task 5609 Finished Mon Sep 18 01:32:01 UTC 2017
Task 5609 Duration 00:00:04
Task 5609 done

Instance   zookeeper/0015b995-5ec3-4519-8c11-6521b0aa079d
Exit Code  0
Stdout     Mode: leader
Stderr     ZooKeeper JMX enabled by default
           Using config: /var/vcap/jobs/zookeeper/config/zoo.cfg

Instance   zookeeper/3e977542-d53e-4630-bc40-72011f853cb5
Exit Code  0
Stdout     Mode: follower
Stderr     ZooKeeper JMX enabled by default
           Using config: /var/vcap/jobs/zookeeper/config/zoo.cfg

Instance   zookeeper/671d5b1d-0310-4735-8f58-182fdad0e8bc
Exit Code  0
Stdout     Mode: follower
Stderr     ZooKeeper JMX enabled by default
           Using config: /var/vcap/jobs/zookeeper/config/zoo.cfg

Instance   zookeeper/d9e00366-8ab1-4ea2-bae3-14cd6bf562cd
Exit Code  0
Stdout     Mode: follower
Stderr     ZooKeeper JMX enabled by default
           Using config: /var/vcap/jobs/zookeeper/config/zoo.cfg

Instance   zookeeper/e31944b9-8bf5-4a42-8d6b-3402a85d24d8
Exit Code  0
Stdout     Mode: follower
Stderr     ZooKeeper JMX enabled by default
           Using config: /var/vcap/jobs/zookeeper/config/zoo.cfg

5 errand(s)

Succeeded
</pre>

If an errand job is colocated on multiple instances (over one or more instance groups), by default `bosh run-errand` command will execute them all in parallel. You can limit number of instances used for execution via `--instance` flag:

<pre class="terminal">
$ bosh -e vbox -d zookeeper run-errand status --instance zookeeper/3e977542-d53e-4630-bc40-72011f853cb5
</pre>

See [`bosh run-errand` command](cli-v2.html#run-errand) description for additional ways to use `--instance` flag.

---
Previous: [Jobs](jobs.html)
