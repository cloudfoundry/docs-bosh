---
title: Sample BOSH Windows Release
---

This is a sample BOSH release than can be deployed using a Windows stemcell. It has a single job called `say-hello` that repeatedly prints out a message.

After creating a deployment with this release and the `say-hello` job you can access the job's standard out with the `bosh log` command (see documentation on [logs](job-logs.html) for more information).

---
## <a id="release-structure"></a> Release Structure

```shell
$ mkdir sample-windows-release
$ cd sample-windows-release
$ bosh init-release --git
$ bosh generate-job say-hello
```

```
jobs/
  say-hello/
    templates/
      post-deploy.ps1
      post-start.ps1
      pre-start.ps1
      start.ps1
    monit
    spec
packages/
```

---
### <a id="say-hello-spec"></a> `spec`

The `spec` file specifies the job name and description. It also contains the templates to render, which may depend on zero or more packages. See the documentation on [job spec files](jobs.html#spec) for more information.

```yaml
---
name: say-hello

description: "This is a simple job"

templates:
  start.ps1: bin/start.ps1

packages: []
```

---
### <a id="say-hello-monit"></a> `monit`

The `monit` file includes zero or more processes to run. Each process specifies an executable as well as any arguments and environment variables. See the documentation on [monit files](jobs.html#monit) for more information. Note, however, that Windows monit files are JSON config files for [Windows service wrapper](https://github.com/kohsuke/winsw), not config files for the monit Unix utility.

```json
{
  "processes": [
    {
      "name": "say-hello",
      "executable": "powershell",
      "args": [ "/var/vcap/jobs/say-hello/bin/start.ps1" ],
      "env": {
        "FOO": "BAR"
      }
    }
  ]
}
```

---
### <a id="start-ps1"></a> `start.ps1`

The `start.ps1` script executed by the [service-wrapper](https://github.com/kohsuke/winsw) loops indefintely while printing out a message:

```powershell
while ($true)
{
  Write-Host "I am executing a BOSH job. FOO=${Env:FOO}"
  Start-Sleep 1.0
}
```

---
## <a id='deploying'></a> Creating and Deploying the Sample Release

If you have the Director with a Windows stemcell uploaded, you can create the above described release with an empty `blobs.yml` and `final.yml`, then try deploying it:

```shell
$ cd sample-windows-release
$ bosh create-release --force
$ bosh upload-release
$ bosh -d sample-windows-deployment deploy manifest.yml
```

For information about deployment basics, see the [Deploy Workflow](basic-workflow.html) documenation.

Here is a sample manifest. For information on manifest basics, see the [Deployment Manifest](deployment-manifest.html) documentation.

```yaml
name: sample-windows-deployment

releases:
- name: sample-windows-release
  version: latest

stemcells:
- alias: windows
  os: windows2012R2
  version: latest

update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 30000-300000
  update_watch_time: 30000-300000

instance_groups:
- name: hello
  azs: [z1]
  instances: 1
  jobs:
  - name: say-hello
    release: sample-windows-release
  stemcell: windows
  vm_type: default
  networks:
  - name: default
```
