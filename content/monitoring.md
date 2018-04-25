BOSH monitors deployed VMs and release jobs' processes on those VMs via the Health Monitor and the help of the Agent, and Monit.

---
## VMs {: #vm }

[The Health Monitor](bosh-components.md#health-monitor) continuously checks presence of the deployed VMs. The Agent on each VM produces a heartbeat every minute and sends it to the Health Monitor over [NATS](bosh-components.md#nats).

The Health Monitor is extended by a set of plugins. Each plugin is given an opportunity to act on each heartbeat, so in cases of failure it can notify external services or perform actions against the Director.

Health Monitor includes the following plugins:

- Event Logger: Logs events to a file
- Resurrector: Recreates VMs that have stopped heartbeating
- Emailer: Sends configurable e-mails on events receipt
- JSON: Sends events over stdin to any executable matching the glob /var/vcap/jobs/*/bin/bosh-monitor/*
- OpenTSDB: Sends events to [OpenTSDB](http://opentsdb.net/)
- Graphite: Sends events to [Graphite](https://graphite.readthedocs.org/en/latest/)
- PagerDuty: Sends events to [PagerDuty.com](http://pagerduty.com) using their API
- DataDog: Sends events to [DataDog.com](http://datadoghq.com) using their API
- AWS CloudWatch: Sends events to [Amazon's CloudWatch](http://aws.amazon.com/cloudwatch/) using their API

See [Configuring Health Monitor](hm-config.md) for detailed plugins' configuration.

### Resurrector Plugin {: #resurrector }

Resurrector plugin continuously cross-references VMs expected to be running against the VMs that are sending heartbeats. When resurrector does not receive heartbeats for a VM for a certain period of time, it will kick off a task on the Director to try to "resurrect" that VM.

See [Automatic repair with Resurrector](resurrector.md) for details.

---
## Processes on VMs {: #process }

Release jobs' process monitoring on each VM is done with the help of the [Monit](http://mmonit.com/monit/). Monit continuously monitors presence of the configured release jobs' processes and restarts processes that are not found. Process restarts, failures, etc. are reported to the Agent which in turn reports them as alerts to the Health Monitor. Each Health Monitor plugin is given an opportunity to act on each alert.

---
## SSH Events {: #ssh }

The Agent on each VM sends an alert when someone/something tries to log into the system via SSH. Successful and failed attempts are recorded.

---
## Deploy Events {: #deploy }

The Director sends an alert when a deployment starts, successfully completes or errors.
