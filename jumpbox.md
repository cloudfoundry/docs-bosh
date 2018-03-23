---
title: Jumpbox
---

It's recommended:

- to maintain a separate jumpbox VM for your environment
- do not SSH to the Director
- use `bosh ssh` to access VMs in your deployments and use jumpbox VM as your SSH gateway

To obtain SSH access specifically to the Director VM when necessary you can opt into `jumpbox-user.yml` ops file when running [`bosh create-env` command](cli-v2.md#create-env). It will add a `jumpbox` user to the VM (by using `user_add` job from `cloudfoundry/os-conf-release`).

```shell
$ bosh int creds.yml --path /jumpbox_ssh/private_key > jumpbox.key
$ chmod 600 jumpbox.key
$ ssh jumpbox@&lt;external-or-internal-ip&gt; -i jumpbox.key
```
