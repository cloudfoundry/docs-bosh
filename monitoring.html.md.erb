---
title: Monitoring
---

BOSH monitors deployed VMs and release jobs' processes on those VMs via the Health Monitor and the help of the Agent, and Monit.

---
## <a id="vm"></a> VMs

[The Health Monitor](bosh-components.html#health-monitor) continiously checks presence of the deployed VMs. The Agent on each VM produces a heartbeat every minute and sends it to the Health Monitor over [NATS](bosh-components.html#nats).

The Health Monitor is extended by a set of plugins. Each plugin is given an opportunity to act on each heartbeat, so in cases of failure it can notify external services or perform actions against the Director.

Health Monitor includes the following plugins:

- Event Logger: Logs events to a file
- Resurrector: Recreates VMs that have stopped heartbeating
- Emailer: Sends configurable e-mails on events reciept
- OpenTSDB: Sends events to [OpenTSDB](http://opentsdb.net/)
- Graphite: Sends events to [Graphite](https://graphite.readthedocs.org/en/latest/)
- PagerDuty: Sends events to [PagerDuty.com](http://pagerduty.com) using their API
- DataDog: Sends events to [DataDog.com](http://datadoghq.com) using their API
- AWS CloudWatch: Sends events to [Amazon's CloudWatch](http://aws.amazon.com/cloudwatch/) using their API

See [Configuring Health Monitor](hm-config.html) for detailed plugins' configuration.

### <a id="resurrector"></a> Resurrector Plugin

Resurrector plugin continiously cross-references VMs expected to be running against the VMs that are sending heartbeats. When resurrector does not receive heartbeats for a VM for a certain period of time, it will kick off a task on the Director to try to "resurrect" that VM.

See [Automatic repair with Resurrector](resurrector.html) for details.

---
## <a id="process"></a> Processes on VMs

Release jobs' process monitoring on each VM is done with the help of the [Monit](http://mmonit.com/monit/). Monit continiously monitors presence of the configured release jobs' processes and restarts processes that are not found. Process restarts, failures, etc. are reported to the Agent which in turn reports them as alerts to the Health Monitor. Each Health Monitor plugin is given an opportunity to act on each alert.

---
## <a id="ssh"></a> SSH Events

The Agent on each VM sends an alert when someone/something tries to log into the system via SSH. Successful and failed attempts are recorded.

---
## <a id="deploy"></a> Deploy Events

The Director sends an alert when a deployment starts, successfully completes or errors.

---
Next: [Process monitoring with Monit](vm-monit.html)
