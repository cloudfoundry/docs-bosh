# Dynamic Disks

!!! note
    This feature is available with bosh-release v282.1.6+. The create, attach, and list operations need bosh-release v283.1.2+.

A dynamic disk is a disk that an API client creates, attaches, detaches, and deletes while a deployment runs. The deployment manifest does not declare it, and a deploy does not change it. Use a dynamic disk when a workload on a VM needs extra storage on demand, for example a volume for a service instance.

Dynamic disks are different from [persistent disks](persistent-disks.md). The Director manages a persistent disk from the manifest. A client of the [Director API](director-api-v1.md#dynamic-disks) manages a dynamic disk. For the design, see [RFC 0053: Dynamic Disks](https://github.com/cloudfoundry/community/blob/main/toc/rfc/rfc-0053-dynamic-disks.md).

---

## Requirements {: #requirements }

- **Director**: bosh-release v282.1.6+. Use v283.1.2+ to get all six API endpoints.
- **Stemcell**: a stemcell with bosh-agent v2.834.0+. The agent must support the `add_dynamic_disk` and `remove_dynamic_disk` messages.
- **CLI**: bosh-cli v7.10.8+ for `bosh disks --dynamic` and `bosh delete-disk --dynamic`.
- **Workers**: set the `director.dynamic_disks_workers` property of the director job to 1 or more. The default is 0. With 0, no Director worker reads the dynamic disks queue, and each dynamic disk task stays in the `queued` state.
- **Disk type**: a [disk type](cloud-config.md#disk-types) in the cloud config. The API calls it `disk_pool_name`. The Director uses the `cloud_properties` of that disk type when it creates the disk.
- **Permissions**: a UAA client or user with the [dynamic disk scopes](director-users-uaa-scopes.md#dynamic-disks), or with `bosh.admin`.

Example operations file for the director job:

```yaml
- type: replace
  path: /instance_groups/name=bosh/jobs/name=director/properties/director/dynamic_disks_workers?
  value: 1
```

---

## Operations {: #operations }

Each write operation starts a [Director task](director-tasks.md). The API response is a redirect to the task.

Disk names are unique on the Director, not only in a deployment.

| Operation | Endpoint | What it does |
|-----------|----------|--------------|
| Provide | `POST /dynamic_disks/provide` | Creates the disk if no disk has that name, then attaches it to the instance. |
| Create | `POST /dynamic_disks` | Creates the disk in a deployment and an availability zone, and does not attach it. |
| Attach | `POST /dynamic_disks/{name}/attach` | Attaches a disk that exists to an instance. |
| Detach | `POST /dynamic_disks/{name}/detach` | Detaches the disk from its VM. The disk stays. |
| Delete | `DELETE /dynamic_disks/{name}` | Deletes the disk in the IaaS and in the Director database. |
| List | `GET /dynamic_disks` | Lists all dynamic disks. |

Rules:

- **Provide** and **attach** succeed again when the disk is already attached to the same VM. They fail when the disk is attached to a different VM.
- **Attach** fails when the disk and the instance are in different availability zones, in different deployments, or use different CPIs.
- **Create** uses an active VM of the deployment in the given availability zone to tell the CPI where to put the disk. The deployment must have an active VM in that zone.
- **Detach** succeeds when the disk is already detached.
- **Delete** succeeds when the disk is already deleted. Detach the disk before you delete it.
- The `metadata` field is optional. When it changes, the Director sends it to the CPI as disk metadata.

The task result of **provide** and **create** has the disk CID, for example `{"disk_cid":"vol-0a1b2c3d"}`. Read it with [`GET /tasks/{id}/output?type=result`](director-api-v1.md#get-task-result).

---

## Disks on the VM {: #on-the-vm }

When the Director attaches a dynamic disk, it sends the disk CID and the disk hint from the CPI `attach_disk` call to the agent. The agent finds the device and makes a symbolic link to it:

```text
/var/vcap/data/dynamic_disks/<DISK-CID>
```

The agent does not partition, format, or mount a dynamic disk. The workload that uses the disk must do these steps. When the Director detaches the disk, the agent removes the link.

---

## Lifecycle {: #lifecycle }

- **VM delete or recreate**: the Director detaches all dynamic disks from the VM before it deletes the VM. This occurs for each recreate, for example a stemcell update or `bosh recreate`. The disks stay, but the Director does not attach them to the new VM. The client must attach each disk again.
- **Deployment delete**: the Director deletes all dynamic disks of the deployment.

---

## Granting permissions {: #permissions }

Example of a UAA client that can use all dynamic disk operations and no other Director operation:

```shell
uaac client add dynamic-disks-client \
  --secret dynamic-disks-secret \
  --authorized_grant_types client_credentials \
  --authorities bosh.dynamic-disks.create,bosh.dynamic-disks.attach,bosh.dynamic-disks.detach,bosh.dynamic-disks.delete,bosh.dynamic-disks.list
```

See [Dynamic disk scopes](director-users-uaa-scopes.md#dynamic-disks) for the scope that each operation needs.

---

## Examples {: #examples }

Provide a 10 GiB disk to an instance. Get the instance ID from `bosh instances`:

```shell
cat > provide.json <<EOF
{
  "instance_id": "209c42e5-3c1a-432a-8445-ab8d7c9f69b0",
  "disk_name": "service-instance-1234",
  "disk_pool_name": "default",
  "disk_size": 10240,
  "metadata": {"service_instance": "1234"}
}
EOF
bosh curl -X POST -H "Content-Type: application/json" --body provide.json /dynamic_disks/provide
```

Detach the disk:

```shell
bosh curl -X POST /dynamic_disks/service-instance-1234/detach
```

List dynamic disks:

```shell
bosh disks --dynamic
```

Delete the disk:

```shell
bosh delete-disk --dynamic service-instance-1234
```
