(See [Variable Interpolation](cli-int.md) for introduction.)

Currently CLI supports `certificate`, `password`, `rsa`, and `ssh` types. The Director (connected to a config server) may support additional types known by the config server.

Note that `<value>` indicates value obtained via `((var))` variable syntax.

---
## Password {: #password }

**<value>** [String]: Password value. When generated defaults to 20 chars (from `a-z0-9`).

---
## Certificate {: #certificate }

**<value>** [Hash]: Certificate.

* **ca** [String]: Certificate's CA (PEM encoded).
* **certificate** [String]: Certificate (PEM encoded).
* **private_key** [String]: Private key (PEM encoded).

Generation options:

* **common_name** [String, required]: Common name. Example: `foo.com`.
* **alternative_names** [Array, options]: Subject alternative names. Example: `["foo.com", "*.foo.com"]`.
* **is_ca** [Boolean, required]: Indicates whether this is a CA certificate (root or intermediate). Defaults to `false`.
* **ca** [String, optional]: Specifies name of a CA certificate to use for making this certificate. Can be specified in conjuction with `is_ca` to produce an intermediate certificate.
* **extended\_key\_usage** [Array, optional]: List of extended key usage. Possible values: `client_auth` and/or `server_auth`. Default: empty. Example: `[client_auth]`.

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

**<value>** [Hash]: RSA key. When generated defaults to 2048 bits.

* **private_key** [String]: Private key (PEM encoded).
* **public_key** [String]: Public key (PEM encoded).

---
## SSH {: #ssh }

**<value>** [Hash]: SSH key. When generated defaults to RSA 2048 bits.

* **private_key** [String]: Private key (PEM encoded).
* **public_key** [String]: Public key (OpenSSH format, "ssh-rsa ...").
* **public\_key\_fingerprint** [String]: Public key's MD5 fingerprint. Example: `c3:ae:51:ec:cb:a8:09:ac:43:fd:84:dd:11:dd:fe:c7`.
