---
title: Configs
---

<p class="note">Note: Generic `configs` functionality is available with bosh-release v264+.</p>

Several configuration files such as cloud config must be specified for the Director to successfully complete a deploy. Even though only cloud config is required, there are other configs like runtime config and CPI config you may want to set. Given that functionality of saving, retrieving, viewing, diffing, and listing for different configs is very similar, Director provides a consolidated CLI and API functionality to support all these actions.

Additionally, in some cases it may be useful to split cloud config and/or other configurations into multiple named files so that they can be managed and evolved separately. For example one team can be setting runtime config with IPSec addon and another team separately can manage Syslog forwarding addon. To achieve separation you can give different names (e.g. `ipsec` and `syslog`) to configs of the same type (e.g. `runtime`).

---
## Director Types <a id='director-types'></a>

There are three built-in types: `cloud`, `runtime` and `cpi`. You can interact with the Director config types just as you have been doing so far via the [`update-cloud-config`](cli-v2.md#cloud-config-mgmt), [`update-runtime-config`](cli-v2.md#runtime-config-mgmt) and [`update-cpi-config`](cli-v2.md#cpi-config-mgmt) CLI commands respectively. By using these commands you will only be able to interact with the `default` named config of the given type. This will be good enough in most cases but like in our example before if you need to create separate configs with different names, you need to use the [`update-config`](cli-v2.md#update-config) command. Keep in mind that if you use the [config commands](cli-v2.md#configs-mgmt) to interact with the built-in types, you still need to comply with the structure of the YAML file for each type.

---
## User defined Types <a id='user-defined-types'></a>

In addition to the Director types an operator can set config of any other type using the [`update-config`](cli-v2.md#update-config) CLI command. The config file can be any file containing valid YAML. Root of the file must be a hash.

One of the use cases for providing such open ended functionality is to provide shared configuration API for supporting BOSH services instead of reimplementing something similar in each service. An upcoming example that will use this feature will be introduction of the `ressurection` config type that will allow operators to define custom resurrection rules, later read and interpreted by the Health Monitor.

---
## Updating and retrieving a config <a id='update'></a>

To add or update a config on the Director use the [`bosh update-config`](cli-v2.md#update-config) CLI command. If you do not provide a name using the `--name` option, `default` will be used.

```shell
$ bosh update-config my-type configs.yml
Using environment '192.168.50.6' as client 'admin'

+ configs:
+   - name: team-a-config
+     properties:
+       ...
+   - name: team-b-config
+     properties:
+       ...

Continue? [yN]: y

Succeeded

$ bosh config my-type
Using environment '192.168.56.6' as client 'admin'

configs:
  - name: team-a-config
    properties:
      ...
  - name: team-b-config
    properties:
      ...
```

Or you could split them into different "branches" using the `--name` option.

```shell
$ bosh update-config my-type --name=team-a config-a.yml
Using environment '192.168.50.6' as client 'admin'

+ configs:
+   - name: team-a-config
+     properties:
+       ...

Continue? [yN]: y

Succeeded

$ bosh config my-type --name=team-a
Using environment '192.168.56.6' as client 'admin'

configs:
  - name: team-a-config
    properties:
      ...

Succeeded

$ bosh update-config my-type --name=team-b config-b.yml
...

$ bosh config my-type --name=team-b
...
```

---
## Listing configs <a id='list'></a>

To list all configs use the [`bosh configs`](cli-v2.md#configs) CLI command.

```shell
$ bosh configs my-type
Using environment '192.168.50.6' as client 'admin'

Type     Name
my-type  default
~        team-a
~        team-b

3 configs

Succeeded
```

You can also filter configs by `type` and/or `name`:

```shell
$ bosh configs --type=my-type --name=team-a
Using environment '192.168.50.6' as client 'admin'

Type     Name
my-type  team-a

1 configs
```

---
## Deleting configs <a id='list'></a>

To delete configs use the [`bosh delete-config`](cli-v2.md#delete-config) CLI command. If you do not provide a name using the `--name=` option, `default` will be used.

```shell
$ bosh delete-config my-type
```
