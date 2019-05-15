!!! note
    This feature is available with bosh-openstack-cpi v28+.

!!! note
    This feature is available with bosh-cli v2.0.40+.

You can create your own OpenStack light stemcells to re-use stemcell images already uploaded to your OpenStack image store. 

**Note:** Future deployments will fail if the stemcell image referenced by a light stemcell is removed from your OpenStack image store.

1. Download the heavy stemcell for which you want to create a light stemcell
1. Upload the stemcell to your OpenStack with `bosh upload-stemcell` and retrieve the CID and version with `bosh stemcells`. In case this is not possible, please read the example [Manually upload stemcell with OpenStack CLI](#example-manually-upload-stemcell-with-openstack-cli)
1. Use `bosh repack-stemcell` to create a light stemcell archive from a heavy stemcell
```shell
bosh repack-stemcell --version "<Stemcell version>" \
--empty-image \
--format openstack-light \
--cloud-properties="{\"image_id\": \"<Stemcell CID>\"}" \
heavy-stemcell.tgz ./light-bosh-stemcell-<Stemcell version>-openstack-kvm-ubuntu-xenial-go_agent.tgz
```

You can use the light stemcell archive like a regular stemcell archive in BOSH deployment manifests and with `bosh create-env` command.



###Example: Manually upload stemcell with OpenStack CLI


Untar the downloaded heavy stemcell and its `image` to extract the `root.img`

```bash
tar -xvf bosh-stemcell-170.12-openstack-kvm-ubuntu-xenial-go_agent.tgz
cd bosh-stemcell-170.12-openstack-kvm-ubuntu-xenial-go_agent
tar -xvf image
```

Upload the `root.img` to the OpenStack project

```bash
openstack image create \
  --container-format bare \
  --disk-format qcow2 \
  --file root.img \
  --property architecture=x86_64 \
  --property auto_disk_config=true \
  --property hypervisor_type=kvm \
  --property os_distro=ubuntu \
  --property os_type=linux \
  --property version=170.12 \
  bosh-openstack-kvm-ubuntu-xenial-go_agent/170.12
```

**Note:** The `stemcell.MF` can be referred to for setting the properties. In case a stemcell has already been uploaded, `openstack image show <Image ID>` may also provide helpful information.

For repacking the heavy stemcell into a light stemcell, the `<Stemcell CID>` can be retrieved from the output of the command above.