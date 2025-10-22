(See [Variable Interpolation](cli-int.md) for introduction.)

Currently CLI supports `password`, `certificate`, `rsa`, `user` and `ssh` types whose
supported generation options are detailed below. The Director (connected to a
config server, typically CredHub) may support additional types known by the
config server.

Please refer to [CredHub documentation][credhub_cred_types] for full details
over CredHub supported credentials types and their associated available
generation options.

Please also refer to [variables block](manifest-v2/#variables) for useful
options like `update_mode: converge` (knowing that when the Bosh CLI generates
secrets in a local `--vars-store` file for `bosh create-env`, the
`update_mode: converge` is not honored, though).

Note that `<value>` indicates value obtained via `((var))` variable syntax.

[credhub_cred_types]: https://docs.cloudfoundry.org/credhub/credential-types.html#cred-types

---
## Password {: #password }

**<value>** [String]: Password value. A random string containing a fixed set
of characters: lowercase letters (from `a` to `z`) and figures (from `0` to
`9`).

Generation options:

* **length** [Number, optional]: The length of password to generate. Defaults
  to `20` with the Bosh CLI (whereas the default length with CredHub [is `30`][credhub_gen_pwd_opts]).

[credhub_gen_pwd_opts]: https://docs.cloudfoundry.org/api/credhub/version/2.9/#_generate_a_password_credential_request_fields

---
## Certificate {: #certificate }

**<value>** [Hash]: Certificate.

* **ca** [String]: Certificate's CA (PEM encoded).
* **certificate** [String]: Certificate (PEM encoded).
* **private_key** [String]: Private key (PEM encoded).
  Since [Sept 8th, 2017][boshcli_priv_key_len], the Bosh CLI generates private
  keys which are `3072` bits long, and doesn't provide any parameter for this,
  whereas CredHub default [is 2048][credhub_gen_cert_opts].

[boshcli_priv_key_len]: https://github.com/cloudfoundry/config-server/blob/0ef502116cccef2370f333d37abe9748df125e95/types/certificate_generator.go#L60
[credhub_gen_cert_opts]: https://docs.cloudfoundry.org/api/credhub/version/2.9/#_generate_a_certificate_credential_request_fields

Generation options:

* **common_name** [String, required]: the Common Name (CN) used in the certificate subject. Example: `foo.com`.
* **organization** [String, optional]: The organization name (O) used in the certificate subject. Defaults to `Cloud Foundry`.
* **alternative_names** [Array, optional]: Subject alternative names. Example: `["foo.com", "*.foo.com"]`.
* **is_ca** [Boolean, required]: Indicates whether this is a CA certificate (root or intermediate). Defaults to `false`.
* **ca** [String, optional]: Specifies name of a CA certificate to use for making this certificate. Can be specified in conjunction with `is_ca` to produce an intermediate certificate.
* **extended\_key\_usage** [Array, optional]: List of extended key usage. Possible values: `client_auth` and/or `server_auth`. Default: `[]` (empty list). Example: `["client_auth"]`.
* **duration** [Number, optional]: Duration in days of generated credential value. Default: `365`. If a minimum duration is configured in CredHub and is greater than the user provided duration, the certificate will be generated using the minimum duration instead.

Example:

```yaml
- name: bosh_ca
  type: certificate
  options:
    is_ca: true
    common_name: bosh
- name: mbus_bootstrap_ssl
  type: certificate
  options:
    ca: bosh_ca
    common_name: ((internal_ip))
    alternative_names: [((internal_ip))]
```

Example of certificates used for mutual TLS:

```yaml
variables:
- name: cockroachdb_ca
  type: certificate
  options:
    is_ca: true
    common_name: cockroachdb
- name: cockroachdb_server_ssl
  type: certificate
  options:
    ca: cockroachdb_ca
    common_name: node
    alternative_names: ["*.cockroachdb.default.cockroachdb.bosh"]
    extended_key_usage:
    - server_auth
    - client_auth
- name: cockroachdb_user_root
  type: certificate
  options:
    ca: cockroachdb_ca
    common_name: root
    extended_key_usage:
    - client_auth
- name: cockroachdb_user_test
  type: certificate
  options:
    ca: cockroachdb_ca
    common_name: test
    extended_key_usage:
    - client_auth
```

---
## RSA {: #rsa }

**<value>** [Hash]: RSA key. The Bosh CLI generates a private key which is
`2048` bits long, and doesn't provide any parameter for this.

* **private_key** [String]: Private key (PEM encoded).
* **public_key** [String]: Public key (PEM encoded).

---
## SSH {: #ssh }

**<value>** [Hash]: SSH key. The Bosh CLI generates a RSA private key which is
`2048` bits long, and doesn't provide any parameter for this.

* **private_key** [String]: Private key (PEM encoded).
* **public_key** [String]: Public key (OpenSSH format, "ssh-rsa ...").
* **public\_key\_fingerprint** [String]: Public key's MD5 fingerprint. Example: `c3:ae:51:ec:cb:a8:09:ac:43:fd:84:dd:11:dd:fe:c7`.
