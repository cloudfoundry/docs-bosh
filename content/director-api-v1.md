!!! note
    Before using the Director API directly, we strongly encourage to consider using the CLI for automation such as performing a scheduled deploy from a CI. We hope that you will open a [GitHub issue](https://github.com/cloudfoundry/bosh/issues) to share your use cases so that we can suggest or possibly make additions to the CLI.

This document lists common API endpoints provided by the Director.

---
## Overview {: #overview }

### Security {: #auth }

All API access should be done over verified HTTPS.

The Director can be configured in two authentication modes: [basic auth](director-users.md#preconfigured) and [UAA](director-users-uaa.md). [Info endpoint](#info) does not require any authentication and can be used to determine which authentication mechanism to use. All other endpoints require authentication.

`401 Unauthorized` will be returned for requests that contain an invalid basic auth credentials or an invalid/expired UAA access token.

### HTTP verbs {: #http-verbs }

Standard HTTP verb semantics are followed:

| Verb | Description |
-------|-------------|
| GET  | Used for retrieving resources. |
| POST/PUT | Used for creating/updating resources. |
| DELETE | Used for deleting resources. |

### HTTP redirects {: #http-verbs }

Any request may result in a redirection. Receiving an HTTP redirection is not an error and clients should follow that redirect. Redirect responses will have a Location header field. Clients should use same authentication method when following a redirect.

### Rate limiting {: #rate-limiting }

Currently no rate limiting is performed.

### Pagination {: #pagination }

Currently none of the resources are paginated.

### Long running operations (aka Director tasks) {: #long-running-ops }

Certain requests result in complex and potentially long running operations against the IaaS, blobstore, or other resources. [`POST /deployments`](#post-deployment) is a good example. Such requests start a [Director task](director-tasks.md) and continue running on the Director after response is returned. Response to such request will be a `302 Moved Temporarily` redirect to a created task resource.

Once a Director task is created, clients can follow its progress by polling [`GET /tasks/{id}`](#get-task) to find out its state. While waiting for the task to finish, different types of logs ([event](#get-task-event), [result](#get-task-result), [debug](#get-task-debug) information, etc.) can be followed to gain insight into what the task is doing.

---
## General {: #general }

### `GET /info`: Info {: #info }

#### Response body schema

**[root]** [Hash]: Director details.

- **name** [String]: Name of the Director.
- **uuid** [String]: Unique ID of the Director.
- **version** [String]: Version of the Director software.
- **user** [String or null]: Logged in user's user name if authentication is provided, otherwise null.
- **cpi** [String]: Name of the CPI the Director will use.
- **user_authentication** [Hash]:
	  - **type** [String]: Type of the authentication the Director is configured to expect.
	  - **options** [Hash]: Additional information provided to how authentication should be performed.
- **features** [Hash]:
	  - **config_server** [Hash]:
		    - **status** [Boolean]: Default false.
		    - **extras** [Hash]:
			      - **urls** [Array]: List of URLs for the Config Server.

#### Notes

- This is the only endpoint that does not require authentication.
- In future `version` will contain version of the deployed BOSH release.

#### Example

```shell
$ curl -s -k https://192.168.50.4:25555/info | jq .
```

```yaml
{
  "name": "Bosh Lite Director",
  "uuid": "2daf673a-9755-4b4f-aa6d-3632fbed8012",
  "version": "1.3126.0 (00000000)",
  "user": null,
  "cpi": "warden_cpi",
  "user_authentication": {
    "type": "basic",
    "options": {}
  }
}
```

---

## Configs {: #configs }

### `GET /configs`: List configs {: #list-configs }

#### Request query

- **latest** [Boolean, required]: Returns latest configs when set to `true`. Otherwise return all configs when set to `false`. Possible values: `true` or `false`. There is no default.
- **type** [String, optional]: Filters list of configs by the given type.
- **name** [String, optional]: Filters list of configs by the given name.

#### Response body schema

**[root]** [Array]: List of configs.

- **id** [String]: ID of the config.
- **name** [String]: Name of the config.
- **type** [String]: Type of the config, i.e. 'cloud', 'cpi', 'runtime'.
- **content** [String]: YAML containing the config manifest.
- **created_at** [Time]: Creation time of the config.
- **deleted** [Boolean]: Soft delete flag.

#### Example

```shell
$ curl -s -k https://192.168.50.4:25555/configs?latest=true | jq .
```

```yaml
[
   {
    "content": "azs:\n- name: z1\n...",
    "id": "1",
    "type": "cloud",
    "name": "default"
  }
]
```

---
### `POST /configs`: Create config. {: #create-config }

#### Request headers

- **Content-Type** must be `application/json`.

#### Request body

The request body consists of a single JSON hash with the following key, value pairs:

- **name** [String]: Name of the config.
- **type** [String]: Type of the config, i.e. 'cloud', 'cpi', 'runtime'.
- **content** [String]: YAML containing the config manifest.

#### Response body schema

**[root]** [Hash]: The newly created config.

- **name** [String]: Name of the config.
- **type** [String]: Type of the config, i.e. 'cloud', 'cpi', 'runtime'.
- **content** [String]: YAML containing the config manifest.
- **created_at** [Time]: Creation time of the config.
- **deleted** [Boolean]: Soft delete flag.

#### Example

```shell
$ curl -s -k -H 'Content-Type: application/json' -d '{"name": "test", "type": "cloud", "content": "--- {}"}' https://192.168.50.4:25555/configs | jq .
```

```yaml
{
  "content": "--- {}",
  "id": "3",
  "type": "cloud",
  "name": "test"
}
```

---
### `POST /configs/diff`: Diff config. {: #diff-config }

#### Request headers

- **Content-Type** must be `application/json`.

#### Request body

The request body consists of a single JSON hash with the following key, value pairs:

- **name** [String]: Name of the config.
- **type** [String]: Type of the config, i.e. 'cloud', 'cpi', 'runtime'.
- **content** [String]: YAML containing the config manifest.

#### Response body schema

**[root]** [Hash]: The changes.

- **diff** [Array]: List of differences.
- **error** [String]: Error description if an error happened.

#### Example

```shell
$ curl -s -k -H 'Content-Type: application/json' -d '{"name": "default", "type": "cloud", "content": "--- {}"}' https://192.168.50.4:25555/configs/diff | jq .
```

```yaml
{
  "diff": [
    [
      "az: z2",
      "added"
    ]
  ]
}
```

---
### `DELETE /configs`: Marks configs as deleted. {: #delete-config }

#### Request Query

- **name** [String]: Name of the config.
- **type** [String]: Type of the config, i.e. 'cloud', 'cpi', 'runtime'.

#### Example

```shell
$ curl -s -k -X DELETE https://192.168.50.4:25555/configs?type=cloud&name=test
```

---
## Tasks {: #tasks }

See [Director tasks](director-tasks.md) for related info.

### `GET /tasks`: List all tasks {: #list-tasks }

#### Response body schema

**[root]** [Array]: List of tasks.

- **id** [Integer]: Numeric ID of the task.
- **state** [String]: Current state of the task. Possible values are: `queued`, `processing`, `cancelled`, `cancelling`, `done`, `error`, `timeout`.
- **description** [String]: Description of the task's purpose.
- **timestamp** [Integer]: todo.
- **result** [String or null]: Description of the task's result. Will not be populated (string) unless tasks finishes.
- **user** [String]: User which started the task.
- **context_id** [String]: Context ID of the task, if provided when task was created, otherwise empty string.

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks?verbose=2&limit=3' | jq .
```

```yaml
[
  {
    "id": 1180,
    "state": "processing",
    "description": "run errand acceptance_tests from deployment cf-warden",
    "timestamp": 1447033291,
    "result": null,
    "user": "admin",
    "context_id": ""
  },
  {
    "id": 1179,
    "state": "done",
    "description": "scan and fix",
    "timestamp": 1447031334,
    "result": "scan and fix complete",
    "user": "admin",
    "context_id": ""
  },
  {
    "id": 1178,
    "state": "done",
    "description": "scan and fix",
    "timestamp": 1447031334,
    "result": "scan and fix complete",
    "user": "admin",
    "context_id": ""
  }
]
```

---
### `GET /tasks?state=...`: List currently running tasks {: #list-current-tasks }

#### Response body schema

See schema [above](#list-tasks).

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks?state=queued,processing,cancelling&verbose=2' | jq .
```

```yaml
[
  {
    "id": 1180,
    "state": "processing",
    "description": "run errand acceptance_tests from deployment cf-warden",
    "timestamp": 1447033291,
    "result": null,
    "user": "admin",
    "context_id": ""
  }
]
```

---
### `GET /tasks?deployment=...`: List tasks associated with a deployment {: #list-deployment-tasks }

Other tasks query params can be applied.

#### Response body schema

See schema [above](#list-tasks).

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks?deploymet=cf-warden' | jq .
```

```yaml
[
  {
    "id": 1180,
    "state": "processing",
    "description": "run errand acceptance_tests from deployment cf-warden",
    "timestamp": 1447033291,
    "result": null,
    "user": "admin",
    "context_id": ""
  }
]
```

---
### `GET /tasks?context_id=...`: List tasks associated with a context ID {: #list-context-tasks }

Other tasks query params can be applied.

#### Response body schema

See schema [above](#list-tasks).

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks?context_id=4528' | jq .
```

```yaml
[
  {
    "id": 1180,
    "state": "processing",
    "description": "run errand acceptance_tests from deployment cf-warden",
    "timestamp": 1447033291,
    "result": null,
    "user": "admin",
    "context_id": "4528"
  }
]
```

---
### `GET /tasks/{id}`: Retrieve single task {: #get-task }

#### Response body schema

**[root]** [Hash]: Task details.

See additional schema details [above](#list-tasks).

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1180' | jq .
```

```yaml
{
  "id": 1180,
  "state": "processing",
  "description": "run errand acceptance_tests from deployment cf-warden",
  "timestamp": 1447033291,
  "result": null,
  "user": "admin",
  "context_id": ""
}
```

---
### `GET /tasks/{id}/output?type=debug`: Retrieve task's debug log {: #get-task-debug }

#### Response body schema

**[root]** [String]: Debug output for the chosen task.

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1180/output?type=debug'
```

```
...
D, [2015-11-09 02:19:36 #32545] [] DEBUG -- DirectorJobRunner: RECEIVED: director.37d8c089-853e-458c-8535-195085b4b7ed.459b05ae-8b69-4679-b2d5-b34e5fef2dcc {"value":{"agent_task_id":"c9f5b328-0656-41f1-631c-e17151be1e18","state":"running"}}
D, [2015-11-09 02:19:36 #32545] [task:1180] DEBUG -- DirectorJobRunner: (0.000441s) SELECT NULL
D, [2015-11-09 02:19:36 #32545] [task:1180] DEBUG -- DirectorJobRunner: (0.000317s) SELECT * FROM "tasks" WHERE "id" = 1180
```

---
### `GET /tasks/{id}/output?type=event`: Retrieve task's event log {: #get-task-event }

#### Response body schema

**[root]** [String]: Result output for the chosen task. Newlines separate valid event JSON records.

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1181/output?type=event'
```

```
...
{
  "time": 1446959491,
  "stage": "Deleting errand instances",
  "tags": [ "smoke_tests" ],
  "total": 1,
  "task": "59d5b228-a732-4c68-6017-31fe5bc9d8c5",
  "index": 1,
  "state": "started",
  "progress": 0
}
{
  "time": 1446959496,
  "stage": "Deleting errand instances",
  "tags": [ "smoke_tests" ],
  "total": 1,
  "task": "59d5b228-a732-4c68-6017-31fe5bc9d8c5",
  "index": 1,
  "state": "finished",
  "progress": 100
}
```

---
### `GET /tasks/{id}/output?type=result`: Retrieve task's result {: #get-task-result }

#### Response body schema

**[root]** [String]: Result output for the chosen task. Contents depend on a type of task.

#### Example of VM details task

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1181/output?type=result'
```

```
...
{"vm_cid":"ec974048-3352-4ba4-669d-beab87b16bcb","disk_cid":null,"ips":["10.244.0.142"],"dns":[],"agent_id":"c5e7c705-459e-41c0-b640-db32d8dc6e71","job_name":"doppler_z1","index":0,"job_state":"running","resource_pool":"medium_z1","vitals":{"cpu":{"sys":"9.1","user":"2.1","wait":"1.7"},"disk":{"ephemeral":{"inode_percent":"11","percent":"36"},"system":{"inode_percent":"11","percent":"36"}},"load":["0.61","0.74","1.10"],"mem":{"kb":"2520960","percent":"41"},"swap":{"kb":"102200","percent":"10"}},"processes":[{"name":"doppler","state":"running"},{"name":"syslog_drain_binder","state":"running"},{"name":"metron_agent","state":"running"}],"resurrection_paused":false}
```

---
## Stemcells {: #stemcells }

### `GET /stemcells`: List all uploaded stemcells {: #list-stemcells }

#### Response body schema

**[root]** [Array]: List of stemcells.

- **name** [String]: Name of the stemcell.
- **version** [String]: Version of the stemcell.
- **operating_system** [String]: Operating system identifier. Example: `ubuntu-trusty` and `centos-7`.
- **cid** [String]: Cloud ID of the stemcell.
- **deployments** [Array]: List of deployments currently using this stemcell version.
    - **name** [String]: Deployment name.

#### Example

```shell
$ curl -v -s -k https://admin:admin@192.168.50.4:25555/stemcells | jq .
```

```yaml
[
  {
    "name": "bosh-warden-boshlite-ubuntu-trusty-go_agent",
    "operating_system": "ubuntu-trusty",
    "version": "3126",
    "cid": "c3705a0d-0dd3-4b67-52b5-50533a432244",
    "deployments": [
      { "name": "cf-warden" }
    ]
  }
]
```

---
## Releases {: #releases }

### `GET /releases`: List all uploaded releases {: #list-releases }

#### Response body schema

**[root]** [Array]: List of releases.

- **name** [String]: Name of the release.
- **release_versions** [Array]: List of versions available.
    - **version** [String]: Version of the release version.
    - **commit_hash** [String]: Identifier in the SCM repository for the release version source code.
    - **uncommitted_changes** [Boolean]: Whether or not the release version was created from a SCM repository with unsaved changes.
    - **currently_deployed** [Boolean]: Whether or not the release version is used by any deployments.
    - **job_names** [Array of strings]: List of job names associated with the release version.

#### Example

```shell
$ curl -v -s -k https://admin:admin@192.168.50.4:25555/releases | jq .
```

```yaml
[
  {
    "name": "bosh-warden-cpi",
    "release_versions": [
      {
        "version": "28",
        "commit_hash": "4c36884a",
        "uncommitted_changes": false,
        "currently_deployed": false,
        "job_names": [ "warden_cpi" ]
      }
    ]
  },
  {
    "name": "test",
    "release_versions": [
      {
        "version": "0+dev.16",
        "commit_hash": "31ef3167",
        "uncommitted_changes": true,
        "currently_deployed": false,
        "job_names": [ "http_server", "service" ]
      },
      {
        "version": "0+dev.17",
        "commit_hash": "e5416248",
        "uncommitted_changes": true,
        "currently_deployed": true,
        "job_names": [ "drain", "errand", "http_server", "pre_start", "service" ]
      },
    ]
  }
]
```

---
## Deployments {: #deployments }

### `GET /deployments`: List all deployments {: #list-deployments }

#### Response body schema

**[root]** [Array]: List of deployments.

- **name** [String]: Name of the deployment.
- **cloud_config** [String]: Indicator whether latest cloud config is used for this deployment. Possible values: `none`, `outdated`, `latest`.
- **releases** [Array]: List of releases used by the deployment.
	  - **name** [String]: Name of the release.
	  - **version** [String]: Version of the release.
- **stemcells** [Array]: List of stemcells used by the deploymemt.
	  - **name** [String]: Name of the stemcell.
	  - **version** [String]: Version of the stemcell.

#### Example

```shell
$ curl -v -s -k https://admin:admin@192.168.50.4:25555/deployments | jq .
```

```yaml
[
  {
    "name": "cf-warden",
    "cloud_config": "none",
    "releases": [
      {
        "name": "cf",
        "version": "222"
      },
      {
        "name": "cf",
        "version": "223"
      }
    ],
    "stemcells": [
      {
        "name": "bosh-warden-boshlite-ubuntu-trusty-go_agent",
        "version": "2776"
      },
      {
        "name": "bosh-warden-boshlite-ubuntu-trusty-go_agent",
        "version": "3126"
      }
    ]
  }
]
```

---
### `GET /deployments?exclude_configs=true&exclude_releases=true&exclude_stemcells=true`: List all deployments without configs, releases, and stemcells {: #list-just-deployments }

#### Response body schema

**[root]** [Array]: List of deployments.

- **name** [String]: Name of the deployment.

#### Example

```shell
$ curl -v -s -k https://admin:admin@192.168.50.4:25555/deployments?exclude_configs=true&exclude_releases=true&exclude_stemcells=true | jq .
```

```yaml
[
  {
    "name": "cf-warden"
  }
]
```

---
### `POST /deployments`: Create/update single deployment {: #post-deployment }

#### Request query

- **recreate** [Boolean]: Whether or not to ignore deletion errors. Possible values: `true` or not present. Default is not present.
- **skip_drain** [String]: Comma separated list of job names that should not run drain scripts during the update. Possible values: `*` to represent all jobs, `<job1>,<job2>` to list job names, or not present. Default is not present.

#### Request headers

- **Content-Type** must be `text/yaml`.
- **X-Bosh-Context-Id** can be optionally configured with a Context ID that can be used to link related BOSH requests

#### Request body scheme

**[root]** [String]: Manifest string. Note that non-exact version values (`latest` value) for releases and stemcells must be resolved before making a request.

#### Response

Creating/updating a deployment is performed in a Director task. Response will be a redirect to a task resource.

---
### `GET /deployments/{name}`: Retrieve single deployment {: #get-deployment }

#### Response body schema

**[root]** [Hash]: Single deployment.

- **manifest** [String]: Last successfully deployed manifest string.

#### Example

```shell
$ curl -v -s -k https://admin:admin@192.168.50.4:25555/deployments/cf-warden | jq .
```

```yaml
{
  "manifest": "---\nname: cf-warden\n...",
}
```

---
### `DELETE /deployments/{name}`: Delete single deployment {: #delete-deployment }

#### Request query

- **force** [Boolean]: Whether or not to ignore deletion errors. Dangerous! Possible values: `true` or not present. Default is not present.

#### Request body

Empty.

#### Response

Deleting a deployment is performed in a Director task. Response will be a redirect to a task resource.

---
## Instances in a deployment {: #instances }

!!! note
    This feature is available with bosh-release v256+.

[Instances](https://bosh.io/docs/terminology.html#instance) represent the expected state of the VMs of a deployment. The actual state of the VMs can be retrieved with the [`vms` endpoints](#vms). `instances` is similar to `vms`, but also contains instances that do not have a VM.

### `GET /deployments/{name}/instances`: List all instances {: #list-instances }

#### Response body schema

**[root]** [Array]: List of instances.

- **agent_id** [String]: Unique ID of the Agent associated with the VM. Could be `nil` if there is no VM for this instance.
- **cid** [String]: Cloud ID of the VM. Could be `nil` if there is no VM for this instance.
- **job** [String]: Name of the job.
- **index** [Integer]: Numeric job index.
- **id** [String]: ID of the instance.
- **expects_vm** [Boolean]: `true` if a VM should exist for this instance.

#### Notes

- This endpoint does not query Agents on the VMs, hence is returned immediately.

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/deployments/example/instances' | jq .
```

```yaml
[
  {
    "agent_id": "c5e7c705-459e-41c0-b640-db32d8dc6e71",
    "cid": "ec974048-3352-4ba4-669d-beab87b16bcb",
    "job": "example_service",
    "index": 0,
    "id": "209b96c8-e482-43c7-9f3e-04de9f93c535",
    "expects_vm": true
  },
  {
    "agent_id": nil,
    "cid": nil,
    "job": "example_errand",
    "index": 0,
    "id": "548d6aa0-eb8f-4890-bd3a-e6b526f3aeea",
    "expects_vm": false
  }
]
```

---
### `GET /deployments/{name}/instances?format=full`: List details of instances {: #list-instances-detailed }

#### Response body schema

**[root]** [String]: For each instance there is one line of JSON. The JSON contains the following details.

- **agent_id** [String]: Unique ID of the Agent associated with the VM.
- **vm_cid** [String]: Cloud ID of the VM.
- **resource_pool** [String]: Name of the resource pool used for the VM.
- **disk_cid** [String or null]: Cloud ID of the associated persistent disk if one is attached.
- **job_name** [String]: Name of the job.
- **index** [Integer]: Numeric job index.
- **resurrection_paused** [Boolean]: Whether or not resurrector will try to bring back the VM is it goes missing.
- **job_state** [String]: Aggregate state of job. Possible values: `running` and other values that represent unhealthy state.
- **ips** [Array of strings]: List of IPs.
- **dns** [Array of strings]: List of DNS records.
- **vitals** [Hash]: VM vitals.
- **processes** [Array of hashes]: List of processes running as part of the job.
- **state** [String]: State of instance
- **vm_type** [String]: Name of [VM type](https://bosh.io/docs/terminology.html#vm-type)
- **az** [String]: Name of [availability zone](https://bosh.io/docs/terminology.html#az)
- **id** [String]: ID of instance
- **bootstrap** [Boolean]: bootstrap property of [instance specific configuration](https://bosh.io/docs/jobs.html#properties-spec)
- **ignore** [Boolean]: Ignore this instance if set to `true`

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/deployments/example/instances?format=full'
< HTTP/1.1 302 Moved Temporarily
< Location: https://192.168.50.4:25555/tasks/1287
...

$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1287' | jq .

$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1287/output?type=result'
```

```
...
{"vm_cid":"3938cc70-8f5e-4318-ad05-24d991e0e66e","disk_cid":null,"ips":["10.0.1.3"],"dns":[],"agent_id":"d927e75b-2a2d-4015-b5cc-306a067e94e9","job_name":"example_service","index":1,"job_state":"running","state":"started","resource_pool":"resource_pool_1","vm_type":"resource_pool_1","vitals":{"cpu":{"sys":"0.3","user":"0.1","wait":"0.0"},"disk":{"ephemeral":{"inode_percent":"5","percent":"32"},"system":{"inode_percent":"34","percent":"66"}},"load":["0.00","0.01","0.10"],"mem":{"kb":"605008","percent":"7"},"swap":{"kb":"75436","percent":"1"}},"processes":[{"name":"beacon","state":"running","uptime":{"secs":1212184},"mem":{"kb":776,"percent":0},"cpu":{"total":0}},{"name":"baggageclaim","state":"running","uptime":{"secs":1212152},"mem":{"kb":8920,"percent":0.1},"cpu":{"total":0}},{"name":"garden","state":"running","uptime":{"secs":1212153},"mem":{"kb":235004,"percent":2.8},"cpu":{"total":0.2}}],"resurrection_paused":true,"az":null,"id":"abe6a4e9-cfca-490b-8515-2893f9e54d20","bootstrap":false,"ignore":false}
{"vm_cid":"86eb5e7e-a1c8-4f7b-a20c-cd696bf80938","disk_cid":"70b3c01c-729e-4335-9630-1f1985a40c99","ips":["10.0.1.5"],"dns":[],"agent_id":"7a54d3bb-f77b-412f-b662-dbff7733a823","job_name":"example_errand","index":0,"job_state":"stopped","state":"stopped","resource_pool":"resource_pool_1","vm_type":"resource_pool_1","vitals":{"cpu":{"sys":"1.3","user":"4.9","wait":"0.1"},"disk":{"ephemeral":{"inode_percent":"0","percent":"0"},"persistent":{"inode_percent":"0","percent":"67"},"system":{"inode_percent":"34","percent":"48"}},"load":["0.00","0.03","0.05"],"mem":{"kb":"227028","percent":"6"},"swap":{"kb":"25972","percent":"1"}},"processes":[{"name":"postgresql","state":"running","uptime":{"secs":1212309},"mem":{"kb":489836,"percent":12.1},"cpu":{"total":0}}],"resurrection_paused":true,"az":null,"id":"548d7aa0-eb8f-4890-bd3a-e9b526f3aeeb","bootstrap":false,"ignore":false}
```

#### Formatted example of details of a single instance

```yaml
{
  "vm_cid": "86eb5e8e-a8c8-4f7b-a20c-cd696bf80938",
  "disk_cid": "70a3c01c-728e-4335-9630-1f1985a40c99",
  "ips": [
    "10.0.1.5"
  ],
  "dns": [],
  "agent_id": "0a54d3bb-f78b-412f-b662-dbff7733a823",
  "job_name": "example_service",
  "index": 0,
  "job_state": "running",
  "state": "started",
  "resource_pool": "resource_pool_1",
  "vm_type": "resource_pool_1",
  "vitals": {
    "cpu": {
      "sys": "1.3",
      "user": "4.9",
      "wait": "0.1"
    },
    "disk": {
      "ephemeral": {
        "inode_percent": "0",
        "percent": "0"
      },
      "persistent": {
        "inode_percent": "0",
        "percent": "67"
      },
      "system": {
        "inode_percent": "34",
        "percent": "48"
      }
    },
    "load": [
      "0.00",
      "0.03",
      "0.05"
    ],
    "mem": {
      "kb": "227028",
      "percent": "6"
    },
    "swap": {
      "kb": "25972",
      "percent": "1"
    }
  },
  "processes": [
    {
      "name": "postgresql",
      "state": "running",
      "uptime": {
        "secs": 1212309
      },
      "mem": {
        "kb": 489836,
        "percent": 12.1
      },
      "cpu": {
        "total": 0
      }
    }
  ],
  "resurrection_paused": true,
  "az": null,
  "id": "548d6aa0-eb8f-4890-bd3a-e9b526f3aeeb",
  "bootstrap": false,
  "ignore": false
}
```

---
## VMs in a deployment {: #vms }

### `GET /deployments/{name}/vms`: List all VMs {: #list-vms }

#### Response body schema

**[root]** [Array]: List of VMs.

- **agent_id** [String]: Unique ID of the Agent associated with the VM.
- **cid** [String]: Cloud ID of the VM.
- **job** [String]: Name of the job.
- **index** [Integer]: Numeric job index.

#### Notes

- This endpoint does not query Agents on the VMs, hence is returned immediately.

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/deployments/cf-warden/vms' | jq .
```

```yaml
[
  {
    "agent_id": "c5e7c705-459e-41c0-b640-db32d8dc6e71",
    "cid": "ec974048-3352-4ba4-669d-beab87b16bcb",
    "job": "doppler_z1",
    "index": 0
  },
  {
    "agent_id": "81f7b585-f3d3-4dbc-8d7c-f76dbe861bdc",
    "cid": "427c1995-2d06-42b2-4218-418150bc31c9",
    "job": "api_z1",
    "index": 0
  }
]
```

---
### `GET /deployments/{name}/vms?format=full`: List VM details {: #list-vms-detailed }

#### Response body schema

**[root]** [String]: Each VM's details are separated by a newline.

- **agent_id** [String]: Unique ID of the Agent associated with the VM.
- **vm_cid** [String]: Cloud ID of the VM.
- **resource_pool** [String]: Name of the resource pool used for the VM.
- **disk_cid** [String or null]: Cloud ID of the associated persistent disk if one is attached.
- **job_name** [String]: Name of the job.
- **index** [Integer]: Numeric job index.
- **resurrection_paused** [Boolean]: Whether or not resurrector will try to bring back the VM is it goes missing.
- **job_state** [String]: Aggregate state of job. Possible values: `running` and other values that represent unhealthy state.
- **ips** [Array of strings]: List of IPs.
- **dns** [Array of strings]: List of DNS records.
- **vitals** [Hash]: VM vitals.
- **processes** [Array of hashes]: List of processes running as part of the job.
- **state** [String]: State of the VM
- **vm_type** [String]: Name of [VM type](https://bosh.io/docs/terminology.html#vm-type)
- **az** [String]: Name of [availability zone](https://bosh.io/docs/terminology.html#az)
- **id** [String]: ID of the VM
- **bootstrap** [Boolean]: bootstrap property of [VM specific configuration](https://bosh.io/docs/jobs.html#properties-spec)
- **ignore** [Boolean]: Ignore this VM if set to `true`

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/deployments/cf-warden/vms?format=full'
< HTTP/1.1 302 Moved Temporarily
< Location: https://192.168.50.4:25555/tasks/1181
...

$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1181' | jq .

$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/tasks/1181/output?type=result'
```

```
...
{"vm_cid":"3938cc70-8f5e-4318-ad05-24d991e0e66e","disk_cid":null,"ips":["10.0.1.3"],"dns":[],"agent_id":"d927e75b-2a2d-4015-b5cc-306a067e94e9","job_name":"example_service","index":0,"job_state":"running","state":"started","resource_pool":"resource_pool_1","vm_type":"resource_pool_1","vitals":{"cpu":{"sys":"0.3","user":"0.1","wait":"0.0"},"disk":{"ephemeral":{"inode_percent":"5","percent":"32"},"persistent":{"inode_percent":"3","percent":"67"},"system":{"inode_percent":"34","percent":"66"}},"load":["0.00","0.01","0.10"],"mem":{"kb":"605008","percent":"7"},"swap":{"kb":"75436","percent":"1"}},"processes":[{"name":"beacon","state":"running","uptime":{"secs":1212184},"mem":{"kb":776,"percent":0},"cpu":{"total":0}},{"name":"baggageclaim","state":"running","uptime":{"secs":1212152},"mem":{"kb":8920,"percent":0.1},"cpu":{"total":0}},{"name":"garden","state":"running","uptime":{"secs":1212153},"mem":{"kb":235004,"percent":2.8},"cpu":{"total":0.2}}],"resurrection_paused":true,"az":null,"id":"abe6a4e9-cfca-490b-8515-2893f9e54d20","bootstrap":false,"ignore":false}
```

#### Example of a single VM details formatted

```yaml
{
  "agent_id": "c5e7c705-459e-41c0-b640-db32d8dc6e71",

  "vm_cid": "ec974048-3352-4ba4-669d-beab87b16bcb",
  "resource_pool": "medium_z1",
  "disk_cid": null,

  "job_name": "doppler_z1",
  "index": 0,
  "resurrection_paused": false,

  "job_state": "running",
  "ips": [ "10.244.0.142" ],
  "dns": [],

  "vitals": {
    "cpu": {
      "sys": "9.1",
      "user": "2.1",
      "wait": "1.7"
    },
    "disk": {
      "ephemeral": {
        "inode_percent": "11",
        "percent": "36"
      },
      "system": {
        "inode_percent": "11",
        "percent": "36"
      }
    },
    "load": [ "0.61", "0.74", "1.10" ],
    "mem": {
      "kb": "2520960",
      "percent": "41"
    },
    "swap": {
      "kb": "102200",
      "percent": "10"
    }
  },

  "processes": [
    {
      "name": "doppler",
      "state": "running"
    },
    {
      "name": "syslog_drain_binder",
      "state": "running"
    },
    {
      "name": "metron_agent",
      "state": "running"
    }
  ]
}
```

---
## Events {: #events }

See [Events](events.md) for info.

### `GET /events`: List events {: #list-events }

#### Response body schema

**[root]** [Array]: List 200 events matching particular criteria. See query params below for filtering options.

- **id** [String]: Event ID.
- **parent_id** [String]: Associated start event ID if this event represents an end of some action.
- **timestamp** [Integer]: Time at which event was recorded.
- **user** [String]: Associated user name. Also can be `_director` for system initiated events. Example: `admin`.
- **action** [String]: Action performed against an object. Example: `create`, `delete`, `update`.
- **object_type** [String]: Type of an affected object. Example: `deployment`, `instance`.
- **object_name** [String]: Identifier of an affected object. Example: `bosh` (deployment), `bosh/db7658b6-de2f-4c94-a261-acaf4c4b7f62` (instance).
- **task** [String]: Associated task ID. Example: `293543`.
- **deployment** [String]: Name of the deployment.
- **error** [String]: Error description if an error happened.
- **context** [Hash]: Additional data specific to this event. For example for update deployment ending event context includes list of releases and stemcells before and after the deployment.

#### Query filters

- **before_id`:** [String]: Event ID.
- **before_time** [String]: Ruby parseable time. Example: `Thu May 4 17:06:40 UTC 2017`.
- **after_time** [String]: Ruby parseable time. Example: `Thu May 4 17:06:40 UTC 2017`
- **task** [String]: Task ID.
- **deployment** [String]: Deployment name.
- **instance** [String]: Instance name.
- **user** [String]: User name.
- **action** [String]: Action.
- **object_type** [String]: Object type.
- **object_name** [String]: Object name.

#### Example

```shell
$ curl -v -s -k https://admin:admin@192.168.50.4:25555/events | jq .
```

```yaml
[
  {
    "id": "3134",
    "parent_id": "3123",
    "timestamp": 1493917600,
    "user": "admin",
    "action": "update",
    "object_type": "deployment",
    "object_name": "bosh",
    "task": "37037",
    "deployment": "bosh",
    "context": {
      "before": {
        "releases": [
          "uaa/27",
          "bosh/261.4+dev.1493403626",
          "bosh-aws-cpi/62+dev.1",
        ],
        "stemcells": [
          "bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3363.9"
        ]
      },
      "after": {
        "releases": [
          "uaa/27",
          "bosh/261.4+dev.1493916984",
          "bosh-aws-cpi/62+dev.1",
        ],
        "stemcells": [
          "bosh-aws-xen-hvm-ubuntu-trusty-go_agent/3363.9"
        ]
      }
    }
  },
  {
    "id": "3133",
    "parent_id": "3132",
    "timestamp": 1493917600,
    "user": "admin",
    "action": "update",
    "object_type": "instance",
    "object_name": "bosh/db7658b6-de2f-4c94-a261-acaf4c4b7f62",
    "task": "37037",
    "deployment": "bosh",
    "instance": "bosh/db7658b6-de2f-4c94-a261-acaf4c4b7f62",
    "context": {}
  }
]
```

---
### `GET /events/{id}`: Retrieve single event {: #get-event }

#### Response body schema

**[root]** [Hash]: Event details.

See additional schema details [above](#list-events).

#### Example

```shell
$ curl -v -s -k 'https://admin:admin@192.168.50.4:25555/events/3133' | jq .
```

```yaml
{
  "id": "3133",
  "parent_id": "3132",
  "timestamp": 1493917600,
  "user": "admin",
  "action": "update",
  "object_type": "instance",
  "object_name": "bosh/db7658b6-de2f-4c94-a261-acaf4c4b7f62",
  "task": "37037",
  "deployment": "bosh",
  "instance": "bosh/db7658b6-de2f-4c94-a261-acaf4c4b7f62",
  "context": {}
}
```

---
### `POST /events`: Create single event {: #post-event }

#### Request body schema

**[root]** [Hash]: Event details.

- **timestamp** [String, optional]: Optionally provide a timestamp when event occurred.
- **action** [String, required]
- **object_type** [String, required]
- **object_name** [String, required]
- **deployment** [String, optional]: Deployment name.
- **instance** [String, optional]: Instance name.
- **error** [String, optional]: Error description.
- **context** [Hash, optional]
