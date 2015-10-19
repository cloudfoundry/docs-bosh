---
title: Director tasks
---

An operator uses the CLI to interact with the Director. Certain CLI commands result in complex and potentially long running operations against the IaaS, blobstore, or other resources. Such commands are associated with a Director task and continue running on the Director even if the CLI disconnects from the Director.

To find out if a CLI command has an associated Director task, look for "Director task [NUM]" in its output:

<pre class="terminal">
$ bosh deploy

Deployment `idora-full-bosh'

Director task 766 # <---

...snip...
</pre>

---
## <a id="active"></a> Currently active tasks

At any time the Director might be performing multiple tasks at once. Active tasks can be in two states: `queued` or `processing`.

To see all currently active tasks:

<pre class="terminal wide">
$ bosh tasks --no-filter

+-----+------------+-------------------------+-------+-------------------------------+--------+
| #   | State      | Timestamp               | User  | Description                   | Result |
+-----+------------+-------------------------+-------+-------------------------------+--------+
| 766 | processing | 2015-01-27 21:39:30 UTC | admin | create deployment             |        |
| 765 | queued     | 2015-01-27 21:35:02 UTC | admin | scheduled SnapshotDeployments |        |
+-----+------------+-------------------------+-------+-------------------------------+--------+

Total tasks running now: 2
</pre>

<p class="note"><strong>Note</strong>: <code>--no-filter</code> flag shows all tasks. Without that flag, the Director returns a subset of running tasks that it deems important.</p>

### <a id="join-active"></a> Joining tasks

Since Director tasks continue to run in the background even if the CLI has disconnected, you can rejoin a task at any time:

<pre class="terminal">
$ bosh task 766

Director task 766

...snip...
</pre>

Tasks can be joined in different output modes:

- `event` (default): human readable high-level events
- `debug`: detailed logs showing all internal communication between the Director and the Agents
- `cpi`: detailed logs showing all requests and responses from the CPI

<pre class="terminal wide">
$ bosh task 766 --debug

Director task 766

I, [2015-01-27T21:33:19.469158 #1769] [0x3fab30147330]  INFO -- TaskHelper: Director Version: 1.2811.0
I, [2015-01-27T21:33:19.469212 #1769] [0x3fab30147330]  INFO -- TaskHelper: Enqueuing task: 766
I, [2015-01-27 21:33:21 #2725] []  INFO -- DirectorJobRunner: Looking for task with task id 766
D, [2015-01-27 21:33:21 #2725] [] DEBUG -- DirectorJobRunner: (0.001125s) SELECT * FROM "tasks" WHERE "id" = 766

...snip...
</pre>

### <a id="cancel-active"></a> Canceling tasks

Tasks can be cancelled before and while they are running. Canceling an active task will not take immediate effect; however, the Director will stop task execution at a next safe checkpoint. To cancel a task, either press `Ctrl+C` while tracking the task or run:

<pre class="terminal">
$ bosh cancel task 766
</pre>

---
## <a id="finished"></a> Finished tasks

The Director keeps a record of tasks that have finished. Finished tasks can be in two states: `done` or `error`.

To view recently finished tasks:

<pre class="terminal extra-wide">
$ bosh tasks recent

+-----+-------+-------------------------+--------+--------------------------+-----------------------------------------------------------+
| #   | State | Timestamp               | User   | Description              | Result                                                    |
+-----+-------+-------------------------+--------+--------------------------+-----------------------------------------------------------+
| 768 | done  | 2015-01-27 21:39:30 UTC | admin  | run errand smoke-tests   | Errand `smoke-tests' completed successfully (exit code 0) |
| 766 | done  | 2015-01-27 21:33:42 UTC | admin  | create deployment        | /deployments/mysql-dep                                    |
| 765 | error | 2015-01-27 21:27:48 UTC | admin  | create deployment        | Timed out pinging to 95206a0e-4dd9-4598-a074-2aee54793f0f |
| 764 | done  | 2015-01-27 21:25:50 UTC | admin  | create stemcell          | /stemcells/bosh-aws-xen-ubuntu-trusty-go_agent/2827       |
| 760 | done  | 2015-01-27 21:25:01 UTC | admin  | create release           | Created release `cf-mysql/16'                             |
| 759 | error | 2015-01-27 21:23:43 UTC | admin  | create release           | No space left on device @ io_write -...                   |
+-----+-------+-------------------------+--------+--------------------------+-----------------------------------------------------------+

Showing 30 recent tasks
</pre>

You can also run `bosh tasks recent [NUM]` to retrieve more tasks.

<p class="note"><strong>Note</strong>: <code>--no-filter</code> flag shows all tasks. Without that flag, the Director returns a subset of finished tasks that it deems important.</p>

### <a id="join-finished"></a> Joining finished tasks

Finished tasks can be joined just like active tasks but only to view their output (see [various output modes](#join-active)). Finished tasks cannot be cancelled.
