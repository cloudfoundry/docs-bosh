!!! note
    Document uses CLI v2.

(See [What is a Stemcell?](stemcell.md) for an introduction to stemcells.)

As described earlier, each deployment can reference one or more stemcells. For a deploy to succeed, necessary stemcells must be uploaded to the Director.

## Finding Stemcells {: #find }

The [stemcells section of bosh.io](http://bosh.io/stemcells) lists official stemcells.

---
## Uploading to the Director {: #upload }

CLI provides [`bosh upload-stemcell` command](cli-v2.md#upload-stemcell).

- If you have a URL to a stemcell tarball (for example URL provided by bosh.io):

    ```shell
    bosh -e vbox upload-stemcell --sha1 0d927b9c5f79b369e646f5c835e33496bf7356c5 \
    https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-xenial-go_agent?v=621.74
    ```

- If you have already downloaded a stemcell on your local machine:

    ```shell
    bosh upload-stemcell ~/Downloads/bosh-stemcell-621.74-warden-boshlite-ubuntu-xenial-go_agent.tgz
    ```

Once the command succeeds you can view all uploaded stemcells in the Director:

```shell
bosh -e vbox stemcells
```

Should result in:

```text
Using environment '192.168.50.6' as client 'admin'

Name                                         Version  OS             CPI  CID
bosh-warden-boshlite-ubuntu-xenial-go_agent  621.74*  ubuntu-xenial  -    e9cac3d6-0261-48a1-67f0-0ee5ba23e23b

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
  os: ubuntu-xenial
  version: 621.74
```
