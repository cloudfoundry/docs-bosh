!!! note
    This feature is available with 3215+ stemcell series.

Certain releases operate more reliably when persistent data is stored using particular filesystem. The Agent currently supports two different persistent disk filesystem types: `ext4` (default) and `xfs`.

Here is an example:

```yaml
instance_groups:
- name: mongo
  instances: 3
  jobs:
  - name: mongo
    release: mongo
  # ...
  persistent_disk: 10_000
  env:
    persistent_disk_fs: xfs
```

Currently this configuration lives in the instance group `env` configuration. (Eventually we will move this configuration onto the disk type where it belongs.) There are few gotchas:

- changing `persistent_disk_fs` in any way (even if just explicitly setting the default of `ext4`) results in a VM recreation (but reuses *same* disk)
- changing `persistent_disk_fs` for an instance group that previously had a persistent disk will not simply reformat existing disk

To move persistent data to a new persistent disk formatted with a new filesystem you have to set `persistent_disk_fs` configuration *and* change the disk size. If there was no existing persistent disk (for example, for a new deployment), the Agent will format it as requested.
