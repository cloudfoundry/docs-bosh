This document describes the usual actions and tools used to drill down failing
VMs issues, and find a root cause.

For troubleshooting specific issues, see also [those tips](tips.md).

---
## Troubleshooting a failed deployment {: #failed-vms }

These are usual steps to do in order to drill down to the root cause for some
VM instance failure.

1. Identify any failing VM instance with `bosh -d <deployment-name> instances`,
   possibly focusing on failing instances with `--failing` or detailing
   failing jobs with `--ps`.

2. `bosh ssh` to some VM having an issue.

3. Become superuser with `sudo -i` for full `root` login, providing `monit` on
   the `$PATH`.

4. Check failing Monit jobs with `monit summary`. Whenever the failure has
   happened at [`pre-atart` stage](job-lifecycle.md#start), this list is empty
   because Monit configuration is not yet assembled.

5. Check for any full disk device with `df -h`.

6. Check for excessive memory consumption or anything suspicious in the
   process tree (like duplicate or zombie processes) with `top` (press `V` for
   tree display, `c` for command line arguments, double-`E` for GiB memory
   units, `e` for MiB process mem units, `W` for persisting the current
   display, `L` for locating some process, `&` for next search result, `k`
   for sending a signal to the process displayed in first line, `q` to quit)

7. Check the logs for failing processes in `/var/vcap/sys/log/<job-name>/*.log`
   and browse them with `less` (press `>` to go to the end of file, use `f` to
   follow latest logs in live mode, press `^C` to stop following)

## Troubleshooting the BOSH Agent {: #agent }

Troubleshooting the BOSH Agent is very unusual, but here we show how you can
display some JSON metadata present on the VM instance, with tools that are
available by default on stemcells.

1. Check the latest BOSH Agent logs with `less /var/vcap/bosh/log/current`

2. Check BOSH Agent initial configuration with `python3 -mjson.tool /var/vcap/bosh/agent.json`

3. Check BOSH Agent dynamic settings with `python3 -mjson.tool /var/vcap/bosh/settings.json | less`

4. Check VM instance role (as from the BOSH deployment manifest: jobs,
   packages, networks, etc) with `python3 -mjson.tool /var/vcap/bosh/spec.json`
