# Uploading Stemcells

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
    bosh -e vbox upload-stemcell \
    https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-noble?v=1.585
    ```

- If you have already downloaded a stemcell on your local machine:

    ```shell
    bosh upload-stemcell ~/Downloads/bosh-stemcell-1.585-warden-boshlite-ubuntu-noble.tgz
    ```

Once the command succeeds you can view all uploaded stemcells in the Director:

```shell
bosh -e vbox stemcells
```

Should result in:

```shell
Using environment '192.168.56.6' as client 'admin'

Name                                         Version  OS             CPI  CID
bosh-warden-boshlite-ubuntu-noble            1.585*   ubuntu-noble   -    e9cac3d6-0261-48a1-67f0-0ee5ba23e23b

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
  os: ubuntu-noble
  version: 1.585
```
