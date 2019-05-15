Sections below only show minimum configuration options to enable plugins. Add them to the deployment manifest for the Health Monitor. See [health_monitor release job properties](http://bosh.io/jobs/health_monitor?source=github.com/cloudfoundry/bosh) for more details.

---
## Event Logger {: #logger }

Enabled by default. No way to turn it off.

---
## Resurrector {: #resurrector }

Restarts VMs that have stopped heartbeating. See [Automatic repair with Resurrector](resurrector.md) for more details.

```yaml
properties:
  hm:
    resurrector_enabled: true
```

---
## Emailer {: #emailer }

Plugin that sends configurable e-mails on events reciept.

```yaml
properties:
  hm:
    email_notifications: true
    email_recipients: [email@gmail.com]
    smtp:
      from:
      host:
      port:
      domain:
      tls:
      auth:
      user:
      password:
```

---
## JSON {: #json }

Enabled by default.

Plugin that sends alerts and heartbeats as json to programs installed on the director over stdin. The plugin will start and manage a process for each executable matching the glob `/var/vcap/jobs/*/bin/bosh-monitor/*`.

---
## OpenTSDB {: #tsdb }

Plugin that forwards alerts and heartbeats to [OpenTSDB](http://opentsdb.net/).

```yaml
properties:
  hm:
    tsdb_enabled: true
    tsdb:
      address: tsdb.your.org
      port: 4242
```

---
## Graphite {: #graphite }

Plugin that forwards heartbeats to [Graphite](https://graphite.readthedocs.org/en/latest/).

```yaml
properties:
  hm:
    graphite_enabled: true
    graphite:
      address: graphite.your.org
      port: 2003
```

---
## PagerDuty {: #pagerduty }

Plugin that sends various events to [PagerDuty.com](http://pagerduty.com) using their API.

```yaml
properties:
  hm:
    pagerduty_enabled:
    pagerduty:
      service_key:
      http_proxy:
```

---
## DataDog {: #datadog }

Plugin that sends various events to [DataDog.com](http://datadoghq.com) using their API.

```yaml
properties:
  hm:
    datadog_enabled: true
    datadog:
      api_key:
      application_key:
      pagerduty_service_name:
```
