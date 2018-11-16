!!! note
    Applies to CLI v2 v2.0.13+.

## General {: #general }

The BOSH CLI v2 differs from v1 in two main ways: it is stateless, and it hyphenates single commands.

<strong>Statelessness</strong>

The BOSH CLI v2 does not store values for a current environment or configuration.
In v1, you set the environment by passing a Director endpoint to `bosh target` and set the deployment by passing a manifest
file to `bosh deployment`. Then you could run `bosh deploy` with no arguments.

In contrast, the BOSH CLI v2 is stateless. To specify a Director instance and deployment manifest to run a command over,
you do one of the following:

* Pass the BOSH environment in with the `-e` flag and the deployment in with the `-d` flag, or
* Set the command shell environment variable `BOSH_ENVIRONMENT` to your Director endpoint or alias and set `BOSH_DEPLOYMENT` to your deployment name. You can also use `bosh alias-env` to create an alias for your BOSH environment configuration, to avoid having to reference the Director endpoint and credential information for every command.

<strong>Hyphenation</strong>

The BOSH v2 CLI also hyphenates single commands that v1 represented as space-separated word pairs.
For example, `bosh delete deployment` in v1 corresponds to `bosh delete-deployment` in v2.

| Before                      | After
|-----------------------------|-----------------------------
| bosh-init deploy <manifest> | bosh create-env <manifest>
| bosh-init delete <manifest> | bosh delete-env <manifest>
| bosh target <ip>            | bosh alias-env my-env -e <ip>
| bosh status                 | bosh env
| bosh -t my-env ...          | bosh -e my-env ...
| bosh -d manifest-path ...   | bosh -d deployment-name ... [3]
| bosh deployment <manifest>  | n/a
| bosh deploy                 | bosh deploy <manifest>
| bosh delete deployment      | bosh delete-deployment
| bosh tasks --no-filter      | bosh tasks
| bosh tasks recent 1000      | bosh tasks -r=1000
| bosh download manifest dep  | bosh manifest
| bosh vms my-dep             | bosh instances
| bosh vms my-dep             | bosh -d my-dep vms

- Most commands require (`--environment`) `-e` and `--deployment` (`-d`) flags
- `--deployment` (`-d`) flag accepts a deployment name instead of a manifest
- bosh-init CLI is now absorbed by the bosh CLI. One binary!
- Variety of commands (create-env/delete-env/etc.) accept simple interpolation flags (`-v/-l`)
- All commands support friendlier non-TTY output, forceful TTY output and `--json` formatting
- All command names now use dashes instead of spaces
- All commands expect 'piece1/piece2' formatting for instances, releases, and stemcells
- `^+C` doesnt ask for task cancellation and just exits CLI command (task continue to run)
- Sorts all tables in a more consistent manner
- Stores configuration file in `~/.bosh/config` instead of `~/.bosh_config`
- Most of the output formatting have changed

---
## Notable differences per command {: #cmd }

- `bosh alias-env` and all commands
    - only allows connections to Director configured with verifiable certificates
    - no longer asks to interactively log in

- `bosh log-in`
    - no longer accepts username or password arguments

- `bosh task`
    - removed `--no-track` flag without replacement

- `bosh tasks`
    - improves argument syntax (`-r` for recent and `-a` for all)

- `bosh deploy`
    - no longer checks or requires `director_uuid` in the deployment manifest
        - to achieve similar safety make sure to give unique deployment names across environments

- `bosh instances`
    - no longer accepts deployment name argument in favor of using global `--deployment` (`-d`) flag

- `bosh vms`
    - no longer accepts deployment name argument in favor of using global `--deployment` (`-d`) flag

- `bosh logs`
    - adds `-f` flag similar to `tail -f` (uses `bosh ssh` command internally)

- `bosh ssh`
    - improves argument syntax, use `ssh --help` for more info
    - support for running commands against multiple machines
    - adds `--opts` flag to pass through options to ssh command for port forwarding etc.
    - adds `-r` flag to collate results from multiple machines

- `bosh scp`
    - improves argument syntax
    - support for running command against multiple machines

- `bosh delete-deployment`
    - removes explicit argument for specifying deployment in favor of global `--deployment` (`-d`) flag

- `bosh add-blob`
    - requires a path to its release destination
    - no longer uses symlinks to manage blobs but rather places file directly into `blobs/`
