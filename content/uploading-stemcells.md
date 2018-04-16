---
title: Upload Stemcells
---

<p class="note">Note: Document uses CLI v2.</p>

(See [What is a Stemcell?](stemcell.md) for an introduction to stemcells.)

As described earlier, each deployment can reference one or more stemcells. For a deploy to succeed, necessary stemcells must be uploaded to the Director.

## Finding Stemcells {: #find }

The [stemcells section of bosh.io](http://bosh.io/stemcells) lists official stemcells.

---
## Uploading to the Director {: #upload }

CLI provides [`bosh upload-stemcell` command](cli-v2.md#upload-stemcell).

- If you have a URL to a stemcell tarball (for example URL provided by bosh.io):

    ```shell
    $ bosh -e vbox upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3468.17 --sha1 1dad6d85d6e132810439daba7ca05694cec208ab
    ```

- If you have a stemcell tarball on your local machine:

    ```shell
    $ bosh upload-stemcell ~/Downloads/bosh-stemcell-3468.17-warden-boshlite-ubuntu-trusty-go_agent.tgz
    ```

Once the command succeeds you can view all uploaded stemcells in the Director:

```shell
$ bosh -e vbox stemcells
Using environment '192.168.50.6' as client 'admin'

Name                                         Version  OS             CPI  CID
bosh-warden-boshlite-ubuntu-trusty-go_agent  3468.17* ubuntu-trusty  -    6c9c002e-bb46-4838-4b73-ff1afaa0aa21

(*) Currently deployed

1 stemcells

Succeeded
```

---
## Deployment Manifest Usage {: #using }

To use uploaded stemcell in your deployment, add stemcells:

```yaml
stemcells:
- alias: default
  os: ubuntu-trusty
  version: 3468.17
```
