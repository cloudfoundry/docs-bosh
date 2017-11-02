---
title: Upload Stemcells
---

<p class="note">Note: Document uses CLI v2.</p>

(See [What is a Stemcell?](stemcell.html) for an introduction to stemcells.)

As described earlier, each deployment can reference one or more stemcells. For a deploy to succeed, necessary stemcells must be uploaded to the Director.

## <a id='find'></a> Finding Stemcells

The [stemcells section of bosh.io](http://bosh.io/stemcells) lists official stemcells.

---
## <a id='upload'></a> Uploading to the Director

CLI provides [`bosh upload-stemcell` command](cli-v2.html#upload-stemcell).

- If you have a URL to a stemcell tarball (for example URL provided by bosh.io):

    <pre class="terminal">
    $ bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3421.9 --sha1 1396d7877204e630b9e77ae680f492d26607461d
    </pre>

- If you have a stemcell tarball on your local machine:

    <pre class="terminal">
    $ bosh upload-stemcell ~/Downloads/bosh-stemcell-3421.9-warden-boshlite-ubuntu-trusty-go_agent.tgz
    </pre>

Once the command succeeds you can view all uploaded stemcells in the Director:

<pre class="terminal">
$ bosh -e vbox stemcells
Using environment '192.168.50.6' as client 'admin'

Name                                         Version  OS             CPI  CID
bosh-warden-boshlite-ubuntu-trusty-go_agent  3421.9*  ubuntu-trusty  -    6c9c002e-bb46-4838-4b73-ff1afaa0aa21

(*) Currently deployed

1 stemcells

Succeeded
</pre>

---
## <a id='using'></a> Deployment Manifest Usage

To use uploaded stemcell in your deployment, add stemcells:

```yaml
stemcells:
- alias: default
  os: ubuntu-trusty
  version: 3421.4
```

---
Next: [Upload Releases](uploading-releases.html)

Previous: [Build Deployment Manifest](deployment-basics.html)
