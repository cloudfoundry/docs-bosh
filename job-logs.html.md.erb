---
title: Location and use of logs
---

This topic describes different types of logs and how to access them.

## <a id="vm-logs"></a> VM logs

You can access logs from any VM:

* via [`bosh ssh` command](sysadmin-commands.html#ssh) to SSH into a VM and look at the log files
* via [`bosh logs` command](sysadmin-commands.html#logs) to download logs from the VM

The following sections describe different types of logs found on each BOSH managed VM.

---
### <a id="job-logs"></a> Job logs

Release jobs on VMs produce logs throughout different lifecycle events. Release authors are strongly encouraged to place release job logs into `/var/vcap/sys/log/<release_job_name>/*.log`, providing a consistent place for the operator to find them.

For example `redis-server` release job will create two log files:

- `/var/vcap/sys/log/redis-server/redis-server.stdout.log`
- `/var/vcap/sys/log/redis-server/redis-server.stderr.log`

To download logs from all release jobs on a specific VM, run `bosh logs <job_name> <index>`.

See additonal information about following job lifecycle events' logs:

- [pre-start script logs](pre-start.html#logs)
- [drain script logs](drain.html#logs)

---
### <a id="errand-logs"></a> Errand logs

BOSH names logs using the errand name and log type, and writes the logs to the `/var/vcap/sys/log/<errand-name>` directory. For example, BOSH writes the stdout log for an errand named "smoke-test" to `/var/vcap/sys/log/smoke-test/smoke-test.stdout.log`.

<p class="note">Note: By default upon errand completion errand VM is deleted, so you cannot access full errand logs. You can use <code>--keep-alive</code> flag when running an errand to keep the VM with its logs.</p>

By default, the CLI outputs errand's output to the screen when it's smaller than 1MB. If you expect errand to generate output larger than 1MB, currently it needs to be redirected to a file and then downloaded.

To save output from an errand VM:

1. In the errand run script, redirect the output to a log.
1. Using the CLI, run `bosh run errand X` with the `--download-logs` option to download the logs.

    By default, the CLI downloads the logs to your present working directory. Use the `--logs-dir destination_directory` option to change this directory.

<pre class="terminal">
$ bosh run errand smoke-tests --download-logs --logs-dir ~/workspace/smoke-tests-logs
</pre>

---
### <a id="monit-logs"></a> Monit logs

The Agent uses Monit to start, restart, and stop release job processes as specified by the release jobs. Monit detects errors and outputs often useful information to its log. Use `tail` to examine the `monit.log` on a VM:

<pre class="terminal">
$ sudo tail -f -n 200 /var/vcap/monit/monit.log
</pre>

---
### <a id="agent-logs"></a> Agent logs

Agent logs contain configuration and runtime information from the Agent running on a VM. Review these logs if the Director sees VM as unresponsive or the Director fails to contact it during its creation.

The Agent stores logs in `/var/vcap/bosh/log/` and outputs most recent content to `/var/vcap/bosh/log/current`.

<pre class="terminal">
$ sudo tail -f -n 200 /var/vcap/bosh/log/current
</pre>

<p class="note">Note: Agent logs are only accessible to the root user.</p>

---
### <a id="log-rotation"></a> Log rotation

BOSH log rotates release job logs with the [Logrotate](http://linuxconfig.org/logrotate) log file management utility. Logrotate is configured by the Agent to act on all `.log` files in the `/var/vcap/sys/log/`, `/var/vcap/sys/log/*/`, and `/var/vcap/sys/log/*/*/` directories.

Following non-configurable settings are used:

* `missingok`: Skip missing log files and do not generate an error message
* `rotate 7`: Keep seven log files at a time
* `compress`: Compress old log files with gzip
* `delaycompress`: Postpone compression of log files until the next rotation cycle
* `copytruncate`: Copy log files, then truncate in place instead of creating new files
* `size 50M`: Rotate log files when they exceed 50 MB in size

Cron runs logrotate script every hour.

---
### <a id="syslog-conf"></a> Syslog configuration

BOSH does not currently offer a built-in way to configure syslog to forward all logs to a remote host. Currently recommended way to do so would be to add a release job to each deployment job that configures syslogd as desired.

---
## <a id="director-logs"></a> Director task logs

When you run a [CLI](bosh-cli.html) command, the Director stores all activities for the specific command in a task log. Review these logs when you experience an issue with a command.

To access Director task logs:

1. Run [`bosh tasks recent`](sysadmin-commands.html#tasks) to find the task number of the command.
1. Run [`bosh task <task_number>`](sysadmin-commands.html#tasks).
