!!! note
    This feature is available with bosh-cli-release <version_to_be_updated>.

The Director has a way to specify global flags for all deploy commands. The deploy config is a YAML file that defines global flags that apply to all deployments.

---
## Updating and retrieving deploy config {: #update }

To update deploy config on the Director use [`bosh update-config --type deploy --name <your_configs_name> <your_file>`](cli-v2.md#update-config) CLI command.

!!! note
    See [example deploy config](#example1) below.

```shell
bosh update-config --type deploy --name test deploy.yml
bosh config --type deploy --name test
```

```text
Acting as user 'admin' on 'micro'

flags:
- recreate
- fix-releases

include:
- test_deployment


```

The Director will apply the specified flags for the specified deployments during the next `bosh deploy` for that deployment.

---
## Example {: #example1 }

```yaml
flags:
  - recreate
  - fix-releases
include:
  - foo
```

You can include and exclude deployments by using EITHER the `include` or `exclude` property. The [example](#example1) above will only apply the flags if the deployment "foo" gets deployed. 
In contrast, the [example](#example2) config below will ensure that only for the "foo" deployment the flags will NOT be applied. Only specifying the `flags` property will apply the flags for all deployments.


```yaml
flags:
  - recreate
  - fix-releases
exclude:
  - foo
```
