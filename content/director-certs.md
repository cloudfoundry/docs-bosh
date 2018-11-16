!!! note
    See [Director SSL Certificate Configuration with OpenSSL](director-certs-openssl.md) if you prefer to generate certs with OpenSSL config.

Depending on you configuration, there are up to three endpoints to be secured using SSL certificates: The Director, the UAA, and the SAML Service Provider on the UAA.

!!! note
    If you are using the UAA for user management, an SSL certificate is mandatory for the Director and the UAA.

!!! note
    Unless you are using a configuration server, your SSL certificates will be stored in the Director's database.

## Generate SSL certificates {: #generate }

You can use CLI v2 `interpolate` command to generate self signed certificates. Even if you use CLI v2 to generate certificates, you can still continue using CLI v1 with the Director.

```yaml
variables:
- name: default_ca
  type: certificate
  options:
    is_ca: true
    common_name: bosh_ca
- name: director_ssl
  type: certificate
  options:
    ca: default_ca
    common_name: ((internal_ip))
    alternative_names: [((internal_ip))]
- name: uaa_ssl
  type: certificate
  options:
    ca: default_ca
    common_name: ((internal_ip))
    alternative_names: [((internal_ip))]
- name: uaa_service_provider_ssl
  type: certificate
  options:
    ca: default_ca
    common_name: ((internal_ip))
    alternative_names: [((internal_ip))]
```

```shell
$ bosh interpolate tpl.yml -v internal_ip=10.244.4.2 --vars-store certs.yml
$ cat certs.yml
```

## Configure the Director to use certificates {: #configure }

Update the Director deployment manifest:

- `director.ssl.key`
    - Private key for the Director (content of `bosh int certs.yml --path /director_ssl/private_key`)
- `director.ssl.cert`
    - Associated certificate for the Director (content of `bosh int certs.yml --path /director_ssl/certificate`)
    - Include all intermediate certificates if necessary
- `hm.director_account.ca_cert`
    - CA certificate used by the HM to verify the Director's certificate (content of `bosh int certs.yml --path /director_ssl/ca`)

Example manifest excerpt:

```yaml
...
jobs:
- name: bosh
  properties:
    director:
      ssl:
        key: |
          -----BEGIN RSA PRIVATE KEY-----
          MII...
          -----END RSA PRIVATE KEY-----
        cert: |
          -----BEGIN CERTIFICATE-----
          MII...
          -----END CERTIFICATE-----
...
```

!!! note
    A `path` to the key or certificate file is not supported.

If you are using the UAA for user management, additionally put certificates in these properties:

- `uaa.sslPrivateKey`
    - Private key for the UAA (content of `bosh int certs.yml --path /uaa_ssl/private_key`)
- `uaa.sslCertificate`
    - Associated certificate for the UAA (content of `bosh int certs.yml --path /uaa_ssl/certificate`)
    - Include all intermediate certificates if necessary
- `login.saml.serviceProviderKey`
    - Private key for the UAA (content of `bosh int certs.yml --path /uaa_service_provider_ssl/private_key`)
- `login.saml.serviceProviderCertificate`
    - Associated certificate for the UAA (content of `bosh int certs.yml --path /uaa_service_provider_ssl/certificate`)

---
## Target the Director {: #target }

After you deployed your Director with the above changes, you need to specify `--ca-cert` when targeting the Director:

```shell
$ bosh --ca-cert <(bosh int certs.yml --path /director_ssl/ca) target 10.244.4.2
```

!!! note
    If your certificates are trusted via system installed CA certificates, there is no need to provide `--ca-cert` option.
