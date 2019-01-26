# CLI

The BOSH CLI is how users should be interacting with the BOSH world. The CLI has many commands, but they fall into a few categories based on what users are trying to do:

 * Operators -- commands for accessing the director to manage deployments and configurations, and interacting with cloud resources.
 * Release Management -- commands for building software that can be deployed with BOSH.
 * Bootstrap Operations -- a couple commands for creating VMs without a director to coordinate them (i.e. deploying the initial director).

Operators will often have multiple directors for various reasons (e.g. staging vs production, AWS vs Google). To support those needs, director commands are always targeted to a specific "environment" with an additional `-e`/`--environment` flag when executing the CLI.


## External Service Dependencies

### Director API

When running operation commands, the CLI communicates with the director over HTTPS where it is very strict on certificate expiration and host matching (no support for untrusted or invalid certificates).


### Blobstore

When running release management commands, the CLI will typically need to communicate with a remote release blobstore where artifacts are stored.


### Bootstrapping

When running bootstrap operations, the CLI will want to communicate with the IaaS and the [BOSH agent](agent.md) services running on the bootstrapped VM.


## Additional Resources

 * [cloudfoundry/bosh-cli](https://github.com/cloudfoundry/bosh-cli) - source code
