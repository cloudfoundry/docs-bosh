---
title: Access Event Logging
---

!!! note
    This feature is available in bosh-release v256+.

Director logs all API access events to syslog under `vcap.bosh.director` topic.

Here is a log snipped found in `/var/log/syslog` in [Common Event Format (CEF)](https://www.protect724.hpe.com/servlet/JiveServlet/downloadBody/1072-102-7-18874/CommonEventFormat%20v22.pdf):

```
May 13 05:13:34 localhost vcap.bosh.director[16199]: CEF:0|CloudFoundry|BOSH|1.0000.0|director_api|/deployments|7|requestMethod=GET src=127.0.0.1 spt=25556 shost=36ff45a2-51a2-488d-af95-953c43de4cec cs1=10.10.0.36,fe80::80a:99ff:fed6:df7d%eth0 cs1Label=ips cs2=X_BOSH_UPLOAD_REQUEST_TIME=0.000&HOST=127.0.0.1&X_REAL_IP=127.0.0.1&X_FORWARDED_FOR=127.0.0.1&X_FORWARDED_PROTO=https&USER_AGENT=EventMachine HttpClient cs2Label=httpHeaders cs3=none cs3Label=authType cs4=401 cs4Label=responseStatus cs5=Not authorized: '/deployments' cs5Label=statusReason
```

And in a more redable form:

```
May 13 05:13:34 localhost vcap.bosh.director[16199]:
CEF:0
CloudFoundry
BOSH
1.3232.0
director_api
/deployments
7

requestMethod=GET
src=127.0.0.1
spt=25556
shost=36ff45a2-51a2-488d-af95-953c43de4cec

cs1=10.10.0.36,fe80::80a:99ff:fed6:df7d%eth0
cs1Label=ips

cs2=X_BOSH_UPLOAD_REQUEST_TIME=0.000&HOST=127.0.0.1&X_REAL_IP=127.0.0.1&X_FORWARDED_FOR=127.0.0.1&X_FORWARDED_PROTO=https&USER_AGENT=EventMachine HttpClient
cs2Label=httpHeaders

cs3=none
cs3Label=authType

cs4=401
cs4Label=responseStatus

cs5=Not authorized: '/deployments'
cs5Label=statusReason
```

---
## Enabling Logging {: #enable }

To enable this feature:

1. Add [`director.log_access_events_to_syslog`](https://bosh.io/jobs/director?source=github.com/cloudfoundry/bosh#p=director.log_access_events_to_syslog) deployment manifest for the Director:

    ```yaml
    properties:
      director:
        log_access_events_to_syslog: true
    ```

1. Optionally colocate [syslog-release's `syslog_forwarder` job](http://bosh.io/jobs/syslog_forwarder?source=github.com/cloudfoundry/syslog-release) with the Director to forward logs to a remote location.

1. Redeploy the Director.

---
[Back to Table of Contents](index.md#director-config)
