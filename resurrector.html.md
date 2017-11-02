---
title: Automatic repair with Resurrector
---

The Resurrector is a plugin to the [Health Monitor](bosh-components.html#health-monitor). It's responsible for automatically recreating VMs that become inaccessible.

The Resurrector continuously cross-references VMs expected to be running against the VMs that are sending heartbeats. When resurrector does not receive heartbeats for a VM for a certain period of time, it will kick off a task on the Director (scan and fix task) to try to "resurrect" that VM. The Director may do one of two things:

- create a new VM if the old VM is missing from the IaaS
- replace a VM if the Agent on that VM is not responding to commands

Under certain conditions the Resurrector will consider the system in the "meltdown" and will stop sending requests to the Director. It will resume submitting scan and fix tasks to the Director once the conditions change.

Resurrection can be turned off per specific deployment job instance or for all VMs managed by the Director via [`bosh vm resurrection` CLI command](sysadmin-commands.html#vm-resurrection).

<p class='note'><strong>Note</strong>: The Health Monitor deploys with the Resurrector plugin disabled by default. To use it, you must enable the Resurrector plugin in your BOSH deployment manifest.</p>

---
## <a id="enable"></a> Enabling and Configuring the Resurrector

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

1. Depending on how you configured [Director user management](director-users.html), credentials are specified in the `user` and `password` properties or using a custom `client` to authenticate with the UAA.

    ### <a id="uaa-client"></a> Option a) Using UAA User Management

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

    ### <a id="preconfigured-users"></a> Option b) Using Preconfigured Users

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


### <a id="customize"></a> Customizing for Your Deployment

For most deployments, you can use the default configuration values. In very small or very large deployments, the default values may need customization, as discussed in the following examples.

#### Small Deployment

If your deployment consists of only five VMs, you may not want the Resurrector to attempt to recreate your entire deployment in the event of a catastrophic failure. In this scenario, we recommend that you set `minimum_down_jobs` to 1 or 2.

#### Large Deployment

If your deployment consists of 1000 VMs, and you use the defaults, the Resurrector notifies the Director to recreate at least five VMs and up to 200 VMs. Depending on your deployment, you may consider even 100 down instances a catastrophic failure. In this scenario, set `percent_threshold` to 5% so that the Director resurrects 50 instances or fewer.

---
## <a id="disable"></a> Disabling the Resurrector

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
## <a id="audit"></a> Viewing the Resurrector's Activity

Since scan and fix tasks on the Director are regular tasks, you can use `bosh tasks --no-filter` command to view currently running/queued Resurrector's activity and `bosh tasks recent --no-filter` to view finished tasks.

---
Next: [Persistent disk snapshotting](snapshots.html)

Previous: [Manual repair with Cloud Check](cck.html)
