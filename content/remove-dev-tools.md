---
title: Removal of compilers and other development tools
---

!!! note
    This feature is available with bosh-release v255.4+ and on 3213+ stemcell series.

It's typically unnecessary to have development tools installed on all VMs in a production environment. All stemcells come with a minimal set of development tools for compilation workers to successfully compile packages.

To see which files and directories will be removed from the stemcell on bootup, unpack stemcell tarball and view `dev_tools_file_list.txt`.

To remove development tools from all non-compilation VMs:

1. Change deployment manifest for the Director:

    ```yaml
    properties:
      director:
        remove_dev_tools: true
    ```

1. Redeploy Director.

1. Run `bosh recreate` for your deployments.
