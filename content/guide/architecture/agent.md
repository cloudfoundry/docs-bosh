# Agent

The agent is a process running on every VM that BOSH manages. It is responsible for configuring the VM to whatever specifications that the Director tells it. It continuously monitors the VM for some basic system and process metrics, emitting lightweight heartbeats back to Director components (e.g. Health Monitor).


## Configuration

The agent is pre-installed into the stemcell with an IaaS-specific configuration file which defines two types of infrastructure-specific settings.


### Static VM Defaults

These include disk mounting and partitioning options, for example.


### Runtime Settings Source

For more dynamic, runtime settings, the agent will pull settings from several sources, depending on what the infrastructure supports. For more details on which sources a specific infrastructure is configured for, see its respective reference page (e.g. [`aws`](../../aws.md)).

Supported settings sources are:

 * CD-ROM
 * Config Drive (cloud-init)
 * File-based
 * Instance Metadata

Some of the settings that agent relies on here are:

 * Director-configured
    * VM-specific certificates used for authenticating API calls
    * Blobstore servers and authentication details
    * Message Bus endpoints and authentication (e.g. NATS)
    * NTP time synchronization servers
 * Deployment-configured (used for specific use cases)
    * Swap configuration
    * VM password overrides
    * Enabling IPv6 support

!!! tip
    For a full list of available options, refer to [source](https://github.com/cloudfoundry/bosh-agent/blob/master/settings/settings.go).


## Service Dependencies


### Message Bus (i.e. NATS)

The [NATS server](nats.md) is used as a Message Bus for RPCs intended for the agent. The agent will establish a connection to the remote NATS server and subscribe to an agent-specific channel where it will listen for commands from the director.

!!! note
    When bootstrapping a VM without a pre-existing director (i.e. with the `create-env` command), a NATS server is not required. Instead, the agent starts an HTTPS server where RPC calls are received.

When using NATS the primary channels used are:

 * `agent.{agent_uuid}` - agent subscribes for RPC messages
 * `hm.agent.alert.{agent_uuid}` - agent emits messages when specific events occur (e.g. processes are unexpectedly stopped)
 * `hm.agent.heartbeat.{agent_uuid}` - agent emits periodic heartbeat messages describing the VM state


### Blobstore

The [blobstore](blobstore.md) is used, primarily, as a download source of packages for installation onto the VM. Agents will also upload logs to the blobstore in response to `fetch-logs` commands. When VMs are responsible for compiling packages from source, they will upload the result after a successful compilation.

!!! tip
    All interactions with the blobstore rely on checksum verification to ensure the integrity of assets.

 * Transport: HTTPS
 * Authentication: Mutual TLS


### Registry

!!! tip
    The registry is being deprecated with recent versions of director, stemcells, and CPIs.

 * Transport: HTTP
 * Authentication: Username, Password

## Additional Reading

 * [cloudfoundry/bosh-agent](https://github.com/cloudfoundry/bosh-agent) - source repository
