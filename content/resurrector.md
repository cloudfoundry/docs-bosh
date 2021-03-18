The Resurrector is a plugin to the [Health Monitor](bosh-components.md#health-monitor). It's responsible for automatically recreating VMs that become inaccessible.

The Resurrector continuously cross-references VMs expected to be running against the VMs that are sending heartbeats. When resurrector does not receive heartbeats for a VM for a certain period of time, it will kick off a task on the Director (scan and fix task) to try to "resurrect" that VM. The Director may do one of two things:

- create a new VM if the old VM is missing from the IaaS
- replace a VM if the Agent on that VM is not responding to commands

Under certain conditions the Resurrector will consider the system in the "meltdown" and will stop sending requests to the Director. It will resume submitting scan and fix tasks to the Director once the conditions change.

Resurrection can be turned off per specific deployment job instance or for all VMs managed by the Director via `bosh update-config --type resurrection`.

!!! note
    The Health Monitor deploys with the Resurrector plugin disabled by default. To use it, you must enable the Resurrector plugin in your BOSH deployment manifest.

---
## Enabling and Configuring the Resurrector {: #enable }

To enable the Resurrector:

1. Change deployment manifest for the Health Monitor (typically colocated with the Director):

    ```yaml
    properties:
      hm:
        resurrector_enabled: true
    ```

1. Optionally change configuration values:
    * **minimum\_down\_jobs** [Integer, optional]: If the total number of instances that are down in a deployment (within time interval T) is below this number, the Resurrector will _always_ request to fix instances. This decision takes precedence to the `percent_threshold` check when the # of down instances ≤ `minimum_down_jobs`. Default is 5.
    * **percent_threshold** [Float, optional]: If the percentage of instances that are down in a deployment (within time interval T) is greater than the threshold percentage, the Resurrector will _not_ request to fix any instance. Going over this threshold is called "meltdown". Default is 0.2 (20%).
    * **time_threshold** [Integer, optional]: Time interval (in seconds) used in the above calculations. Default is 600.

    ```yaml
    properties:
      hm:
        resurrector_enabled: true
        resurrector:
          minimum_down_jobs: 5
          percent_threshold: 0.2
          time_threshold: 600
    ```

1. Depending on how you configured [Director user management](director-users.md), credentials are specified in the `user` and `password` properties or using a custom `client` to authenticate with the UAA.

    ### Option a) Using UAA User Management {: #uaa-client }

    Define an additional client in the `uaa.clients` section of your manifest:

    ```yaml
    properties:
      uaa:
        clients:
          hm:
            override: true
            authorized-grant-types: client_credentials
            scope: ""
            authorities: bosh.admin
            secret: "hm-password"
    ```

    Configure the Health Monitor to use the client with the defined secret to authenticate with the Director:

    ```yaml
    properties:
      hm:
        director_account:
          client_id: hm
          client_secret: "hm-password"
    ```

    ### Option b) Using Preconfigured Users {: #preconfigured-users }

    Create new Director user so that the Resurrector plugin can communicate with the Director and query/submit information about deployments.

    ```yaml
    properties:
      director:
        user_management:
          provider: local
          local:
            users:
            - {name: admin, password: admin-password}
            - {name: hm, password: hm-password}
    ```

    Configure the Health Monitor to use the HM user and password to authenticate with the Director:

    ```yaml
    properties:
      hm:
        director_account:
          user: hm
          password: hm-password
    ```

1. Deploy.


### Customizing for Your Deployment {: #customize }

For most deployments, you can use the default configuration values. In very small or very large deployments, the default values may need customization, as discussed in the following examples.

#### Small Deployment

If your deployment consists of only five VMs, you may not want the Resurrector to attempt to recreate your entire deployment in the event of a catastrophic failure. In this scenario, we recommend that you set `minimum_down_jobs` to 1 or 2.

#### Large Deployment

If your deployment consists of 1000 VMs, and you use the defaults, the Resurrector notifies the Director to recreate at least five VMs and up to 200 VMs. Depending on your deployment, you may consider even 100 down instances a catastrophic failure. In this scenario, set `percent_threshold` to 5% so that the Director resurrects 50 instances or fewer.

---
## Enabling the Resurrector with Resurrection Config {: #enable-with-resurrection-config }

!!! tip "Beta Feature"
    This `resurrection` config method was first introduced in [v267.2.0](https://github.com/cloudfoundry/bosh/releases/tag/v267.2). We currently do not migrate existing resurrection state to this new configuration method, but are considering it as we improve the UX around this feature. Until we resolve that, test with caution. When used together with the `update-resurrection` cli command, be aware of that pausing resurrection with the cli command takes precedence. It's recommended to either use resurrection config or the cli command, but to not mix them.

It is possible to configure resurrection based on deployments and instance group names using a Resurrection Configuration file. These files override default resurrection behavior and instruct the BOSH director to resurrect (or not) based on the deployment and instance group names.

The resurrection state will be updated directly after updating the resurrection config and does not require further actions. For example:

1. Upload a resurrection config, which disables resurrection.
2. Delete a VM of a deployment (VM gets not resurrected).
3. Upload a resurrection config, which enables resurrection.
4. Missing VM will be resurrected.


### Structure of resurrection config

```yaml
rules:
- enabled: {true,false}
  include: # (optional)
    deployments: # (optional, one of [deployments, instance_groups] must be present)
    - _deployment name1_
    - _deployment name2_
    instance_groups: # (optional)
    - _instance group1_
    - _instance group2_
  exclude: # (optional)
    deployments: # (optional, one of [deployments, instance_groups] must be present)
    - _deployment name1_
    - _deployment name2_
    instance_groups: # (optional)
    - _instance group1_
    - _instance group2_
```

**Parameters:**

- `rules` - a list of resurrection rules. When resurrection rules are interpreted for a given instance, all resurrection rules from all resurrection configs are considered for matching. If no rule matches, resurrection config considers resurrection as `enabled`.
- `enabled` - a boolean which enables (`true`) or disables (`false`) resurrection.
- `exclude` *(Optional)* - a resurrection rule which will result in the resurrection configuration being overridden wherever the specified constraints do not match.
- `include` *(Optional)* - a resurrection rule which will result in the resurrection configuration being overridden wherever the specified constraints match.
- `deployments` *(Optional)* - a list of deployments which can be used as a filter for the include/exclude directives.
- `instance_groups` *(Optional)* - a list of instance groups which can be used as a filter for the include/exclude directives.


### General

* When specifying both properties, `instance_groups` and `deployments`, the rule is only applied for the instance groups of the specified deployments.
* When only `instance_groups` is specified, the rule will be applied to all matching instance groups across **all** deployments.
* Multiple rules are evaluated by the `&` operator. This means, if one rule with `enabled: false` matches for a given instance resurrection for this instance is disabled.


### Examples

By default, resurrection is turned on and the following examples demonstrate how this default can be overwritten.

1. Disable resurrection for a deployment `dep1` by creating a `resurrection.yml`:

	```yaml
	rules:
	- enabled: false
	  include:
	    deployments:
	    - dep1
	```
	Running `bosh update-config --type resurrection --name disable-dep1 resurrection.yml` disables resurrection for all deployments in the include block, i.e. `dep1`. For all other deployments, resurrection is still enabled.

2. Disable resurrection for an instance group `instance-group-1` of a deployment `dep1` by creating a `resurrection.yml`:

	```yaml
	rules:
	- enabled: false
	  include:
	  	 deployments:
	  	 - dep1
	    instance_groups:
	    - instance-group-1
	```

	Running `bosh update-config --type resurrection --name disable-dep1-instance-group-1 resurrection.yml` disables resurrection for all instance groups of all the specified deployments, i.e. `instance-group-1` of deployment `dep1`. For all other instance groups and deployments, resurrection is still enabled.

3. Disable resurrection for all deployments except for deployment `dep1` by creating a `resurrection.yml`:

	```yaml
	rules:
	- enabled: false
	  exclude:
	    deployments:
	    - dep1
	```
	Running `bosh update-config --type resurrection --name disable-all-but-dep1 resurrection.yml` disables resurrection for all deployments except deployment `dep-1`.


### Disabling resurrection globally

Resurrection can be disabled on all deployments with the [`update-resurrection` CLI command](cli-v2.md#update-resurrection):

```sh
bosh update-resurrection off
```

Resurrection can then be re-enabled on all deployments with:
```sh
bosh update-resurrection on
```

Alternatively, resurrection can be disabled on all deployments with this config:

```yaml
rules:
- enabled: false
```

Both the CLI command and resurrection config options are meant to temporarily disable resurrection while you diagnose other issues. You should update the deployment manifest to permanently [disable the Resurrector](#disable).

---
## Disabling the Resurrector {: #disable }

To disable the Resurrector:

1. Change deployment manifest for the Health Monitor (typically colocated with the Director):

    ```yaml
    properties:
      hm:
        resurrector_enabled: false
    ```

1. Redeploy.

1. Optionally remove Director user created for the Health Monitor.

---
## Viewing the Resurrector's Activity {: #audit }

The Resurrector creates scan and fix tasks on the Director using the Health Monitor user. Since these are normal tasks, you can use the `tasks` CLI command to view them.

To view currently running  / queued Resurrector activity, run the following and look for results with Description "scan and fix" and User corresponding to the Health Monitor user in your deployment:

```sh
bosh tasks --all -d ''
```

Similarly, to view finished Resurrector activity, run the following and look for results with Description "scan and fix" and User corresponding to the Health Monitor user in your deployment:

```sh
bosh tasks --recent --all -d ''
```

