---
title: CLI Variable Interpolation
---

<p class="note">Note: Applies to CLI v2.</p>

It's typically necessary to separate passwords, certificates, S3 bucket names etc. from YAML documents used with CLI commands such as `bosh create-env` and `bosh deploy`. Even though the structure of a YAML document (manifest) does not change these values are typically different. CLI provides special syntax in YAML documents to annotate such values making plain YAML document into a parameterized template.

<p class="note">Note: Changing structure of a YAML document such as adding an S3 access configuration section is a bit more than just YAML document parameterization. Look into [operations files](cli-ops-files.html) for additional details.</p>

---
## <a id="variables"></a>  Variables

Variables provide a way to define parameters for a YAML document. Each variable has a value, one or more reference locations and an optional type and generation options.

### <a id="implicit"></a> Implicit declaration

Following example shows how to add two variables to a YAML document (`base.yml`):

```yaml
s3_access_key_id: ((access_key_id))
s3_access_secret_key: ((access_secret_key))
```

`access_key_id` and `access_secret_key` variables are implicitly defined just by being present within double parentheses. By parameterizing above YAML document it can now be used as a template.

### <a id="value-sources"></a> Value sources

Commands that accept YAML documents such as `bosh deploy` and `bosh update-cloud-config` typically have a set of flags that can be used to provide variable values. `bosh interpolate` command can be used to experiment with such flags as its only job is to print result of variable interpolation.

<p class="note">Note that once Director officially supports config server API, it will be recommended to use connected config server to store variable values instead of providing them via CLI flags.</p>

CLI allows to provide variable values via usage of one or more of the following flags:

- `--var=key=val` (`-v`) flag sets single variable value as an argument

    <pre class="terminal">
    $ bosh interpolate base.yml -v access_key_id=some-key -v access_secret_key=some-secret
    s3_access_key_id: some-key
    s3_access_secret_key: some-secret
    </pre>

- `--var-file=key=path` flag sets single variable value as an entire file

    <pre class="terminal">
    $ cat 1.yml
    some-key

    $ cat 2.yml
    some-secret

    $ bosh interpolate base.yml --var-file access_key_id=1.txt --var-file access_secret_key=2.txt
    s3_access_key_id: some-key
    s3_access_secret_key: some-secret
    </pre>

- `--vars-file=path` (`-l`) flag sets file that contains multiple variable values

    <pre class="terminal">
    $ cat secrets.yml
    access_key_id: some-key
    access_secret_key: some-secret

    $ bosh interpolate base.yml -l secrets.yml
    s3_access_key_id: some-key
    s3_access_secret_key: some-secret
    </pre>

- via [`--vars-store=path` flag](#vars-store) flag sets file that contains multiple variable values (with a possibility that missing variables will be automatically generated)

- `--vars-env=prefix` flag sets variable values found in prefixed environment variables (casing is important)

    <pre class="terminal">
    $ export FOO_access_key_id=some-key
    $ export FOO_access_secret_key=some-secret

    $ bosh interpolate base.yml --vars-env FOO
    s3_access_key_id: some-key
    s3_access_secret_key: some-secret
    </pre>

Here is a more realistic example of using base YAML document (`bosh.yml`) from [cloudfoundry/bosh-deployment repo](https://github.com/cloudfoundry/bosh) and specifying several variables and operations files to provide necessary missing values:

<pre class="terminal">
$ bosh create-env ~/workspace/bosh-deployment/bosh.yml \
  --state state.json \
  --vars-store ./creds.yml
  -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
  -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
  -o ~/workspace/bosh-deployment/bosh-lite.yml \
  -o ~/workspace/bosh-deployment/jumpbox-user.yml \
  -v director_name=vbox \
  -v internal_ip=192.168.56.6 \
  -v internal_gw=192.168.56.1 \
  -v internal_cidr=192.168.56.0/24 \
  -v network_name=vboxnet0 \
  -v outbound_network_name=NatNetwork
</pre>

### <a id="explicit"></a> Explicit declaration

In addition to just implicitly declaring variables it may be useful to explicitly declare them and provide additional details about used variables so that either the CLI or the Director (actually connected config server) can validate, automatically store and generate variable values.

Dedicated top level `variables` section exists where variable definitions are specified:

```yaml
variables:
- name: admin_password
  type: password
- name: postgres_password
  type: password
- name: default_ca
  type: certificate
  options:
    is_ca: true
    common_name: bosh-ca
- name: director_ssl
  type: certificate
  options:
    ca: default_ca
    common_name: ((internal_ip))
    alternative_names: [((internal_ip))]
```

A variable can define its type and generation options.

### <a id="vars-store"></a> `--vars-store` flag

`--vars-store=path` flag provides a read write value source unlike all other variables flags that provide read only source. It is able to lazily generate and save (to a given file location) variable values based on their type and options.

<p class="note">Note that once Director officially supports config server API, it will be recommended to avoid using `--vars-store` flag for all commands except `bosh create-env`. `bosh create-env` command will not be able to use config server API since it most likely will be deploying a config server alongside the Director.</p>

Currently CLI supports `certificate`, `password`, `rsa`, and `ssh` types. The Director (connected to a config server) may support additional types known by the config server.

See [Variable Types](variable-types.html) for details on variable generation.

<pre class="terminal">
$ cat base.yml
pass: ((admin_password))
variables:
- name: admin_password
  type: password

$ bosh interpolate base.yml --vars-store=creds.yml
pass: vbvdhjbzqelnq7cfyw09

$ cat creds.yml
admin_password: vbvdhjbzqelnq7cfyw09
</pre>

---
[Back to Table of Contents](index.html#cpi-config)

Previous: [Operations Files](cli-ops-files.html)
