---
title: Properties - Suggested configurations
---

## TLS configuration {: #tls }

Following is a _suggested_ set of properties for TLS configuration:

* **tls** [Hash]: TLS configuration section.
    * **enabled** [Boolean, optional]: Enable/disable TLS. Default should be `true`.
    * **cert** [Hash]: Value described by [`ceritificate` variable type](variable-types.md#certificate). Default is `nil`.
    * **protocols** [String, optional]: Space separated list of protocols to support. Example: `TLSv1.2`.
    * **ciphers** [String, optional]: OpenSSL formatted list of ciphers to support. Example: `!DES:!RC4:!3DES:!MD5:!PSK`.

Example job spec:

```yaml
name: app-server

properties:
  tls.enabled:
    description: "Enable/disable TLS"
    default: true
  tls.cert:
    type: certificate
    description: "Specify certificate"
  ...
```

Example manifest usage:

```yaml
instance_groups:
- name: app-server
  instances: 2
  jobs:
  - name: app-server
    properties:
      tls:
        cert: ((app-server-tls))
  ...

variables:
- name: app-server-tls
  type: certificate
  options:
    ...
```

Note that if your job requires multiple TLS configurations (for example, for a client and server TLS configurations), configuration above would be nested under particular context. For example:

```yaml
name: app-server

properties:
  server.tls.enabled:
    description: "Enable/disable TLS"
    default: true
  server.tls.cert:
    type: certificate
    description: "Specify server certificate"

  client.tls.enabled:
    description: "Enable/disable TLS"
    default: true
  client.tls.cert:
    type: certificate
    description: "Specify client certificate"
  ...
```

Example manifest usage:

```yaml
instance_groups:
- name: app-server
  instances: 2
  jobs:
  - name: app-server
    properties:
      server:
        tls:
          cert: ((app-server-tls))
      client:
        tls:
          cert: ((app-client-tls))
  ...

variables:
- name: app-server-tls
  type: certificate
  options:
    ...
- name: app-client-tls
  type: certificate
  options:
    ...
```

---
## Environment proxy configuration {: #env-proxy }

Following is a _suggested_ set of properties for environment proxy configuration:

* **env** [Hash]
    * **http_proxy** [String, optinal]: HTTP proxy that software should use. Default: not specified.
    * **https_proxy** [String, optinal]: HTTPS proxy that software should use. Default: not specified.
    * **no_proxy** [String, optinal]: List of comma-separated hosts that should skip connecting to the proxy in software. Default: not specified.

Example job spec:

```yaml
name: app-server

properties:
  env.http_proxy:
    description: HTTP proxy that the server should use
  env.https_proxy:
    description: HTTPS proxy that the server should use
  env.no_proxy:
    description: List of comma-separated hosts that should skip connecting to the proxy in the server
  ...
```

Example manifest usage:

```yaml
instance_groups:
- name: app-server
  instances: 2
  jobs:
  - name: app-server
    properties:
      env:
        http_proxy: http://10.203.0.1:5187/
        https_proxy: http://10.203.0.1:5187/
        no_proxy: localhost,127.0.0.1
  ...
```
