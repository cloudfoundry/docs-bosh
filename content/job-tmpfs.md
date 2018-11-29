Job configuration often contains credentials. In some environments we do not want these values to be written to a physical disk and only ever want them to be resident in memory. The director has been able to avoid writing credentials to disk for some time now but they would be written to disk on the deployment VMs.

The job directory on `tmpfs` feature makes sure that the agent does not write these values to disk and instead keeps them on an in-memory `tmpfs`.

## Director Disk

The director can be configured to load credentials from a secret store, perform all job template rendering in-memory, and then send the rendered templates over the message bus directly to the agent. For a complete solution, the `enable_nats_delivered_templates` feature should be enabled at the same time as the `tmpfs` agent feature.


```
- name: bosh
  ...
  properties:
    ...
    director:
      ...
      enable_nats_delivered_templates: true
```

If you are using a recent [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment) then this is probably already enabled by default.

## Caveats

* Due to the job configuration and credentials only being stored in-memory, it is not possible to successfully reboot VMs which have this feature enabled. VMs must instead be recreated in order to repopulate them with configuration and bring them back to a healthy state.

* The `tmpfs` is 100MB in size by default. We found that this leaves ample room for most job templates as they are normally small. However, there is a configuration option to increase the size of the allocated `tmpfs` disk if necessary.

---

## Job Configuration

This feature can be enabled by setting the following `env` properties in your deployment manifest.

```yaml
instance_groups:
- name: zookeeper
  ...
  env:
    bosh:
      job_dir:
        tmpfs: true
        tmpfs_size: 128m
```
