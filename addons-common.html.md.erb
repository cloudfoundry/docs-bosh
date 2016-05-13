---
title: Common Addons
---

(See [runtime config](runtime-config.html#addons) for an introduction to addons.)

## <a id='syslog'></a> Syslog forwarding

Need: Configure syslog on all machines to forward system logs to a remote location.

```yaml
releases:
- name: syslog
  version: 3

addons:
- name: logs
  jobs:
  - name: syslog_forwarder
    release: syslog
  properties:
    syslog:
      address: logs4.papertrail.com
      transport: tcp
      port: 38559
      tls_enabled: true
      permitted_peer: "*.papertrail.com"
      ca_cert: |
        -----BEGIN CERTIFICATE-----
        MIIClTCCAf4CCQDc6hJtvGB8RjANBgkqhkiG9w0BAQUFADCBjjELMAk...
        -----END CERTIFICATE-----
```

See [syslog_forwarder job](https://bosh.io/jobs/syslog_forwarder?source=github.com/cloudfoundry/syslog-release).

---
## <a id='login-banner'></a> Custom SSH login banner

<p class="note">Note: This job work with 3232+ stemcell series due to how sshd is configured.</p>

Need: Configure custom login banner to comply with organizational regulations.

```yaml
releases:
- name: os-conf
  version: 3

addons:
- name: misc
  jobs:
  - name: login_banner
    release: os-conf
  properties:
    login_banner:
      text: |
        This computer system is for authorized use only. All activity is logged and
        regularly checked by system administrators. Individuals attempting to connect to,
        port-scan, deface, hack, or otherwise interfere with any services on this system
        will be reported.
```

See [login_banner job](https://bosh.io/jobs/login_banner?source=github.com/cloudfoundry/os-conf-release).

---
## <a id='misc-users'></a> Custom SSH users

<p class="note">Warning: This job does not remove users from the VM when user is removed from the manifest.</p>

Need: Provide SSH access to all VMs for a third party automation system.

```yaml
releases:
- name: os-conf
  version: 3

addons:
- name: misc
  jobs:
  - name: user_add
    release: os-conf
  properties:
    users:
    - name: nessus
      public_key: "ssh-rsa AAAAB3NzaC1yc2EAQCyKb5nLZv...oYPkLlOGyAFLk6Id75Xr hostname"
    - name: teleport
      public_key: "ssh-rsa AAAAB3NzaC1yc2dfgJKkb5nLZv...dkjfLlOGyAFLk6kfbgYG hostname"
```

See [user_add job](https://bosh.io/jobs/user_add?source=github.com/cloudfoundry/os-conf-release).
