BOSH is used by several different groups of people with different needs and goals. Here are the primary personas and their responsibilities that we typically consider...


## Release Author

A release author is interested in how software can be deployed and run with BOSH. They will typically be familiar with both the underlying software which will be deployed, and BOSH conventions around how BOSH supports configuring and installing the software. They will want to understand...

 * The target software...
    * What it means to run it at scale and in production.
    * What settings users need to configure.
    * What conventions the software may have and users expect.
    * What dependencies the software may need.
    * What upgrade workflows are effective.
 * BOSH strategies for managing software...
    * How to write compilation scripts for the software.
    * How to write runtime scripts for running the software.
    * How to manage versions of their release.
    * How deployment operators expect to deploy their release.

Some examples of Release Authors are...

 * Diego team managing [cloudfoundry/diego-release](https://github.com/cloudfoundry/diego-release) - this release is dedicated to deploying the Diego component of Cloud Foundry Application Runtime.
 * Concourse team managing [concourse/concourse](https://github.com/concourse/concourse) - this release integrates several Concourse-specific components into a set of software which makes sense to deploy.
 * Datadog team managing [DataDog/datadog-agent-boshrelease](https://github.com/DataDog/datadog-agent-boshrelease) - this release forwards telemetry and other monitoring information to the Datadog hosted services.


## Deployment Author

A deployment author is interested in making it easier for others to deploy releases in a pre-configured way. They may not be directly responsible for creating releases and defining how they're configured, nor managing the software running in production. They will want to understand...

 * How release authors expose services and configuration of their software.
 * How deployment operators are interested in running the software or set of services.
 * When integrating multiple components...
    * Which versions of components are safe to integrate with each other.
    * Which feature sets may need to be optional or configured (likely with “ops files”)

Some examples of Deployment Authors are...

 * Release Integration team managing [cloudfoundry/cf-deployment](https://github.com/cloudfoundry/cf-deployment) - this deployment brings together numerous releases to manage a set of versions and features which can be used to deploy Cloud Foundry.
 * Teams developing [PCF tiles](https://docs.pivotal.io/tiledev/2-0/) (Tile Authors) - a tile integrates some customization options for managing deployments and services with Pivotal's Ops Manager product.


## Operator

Operators are responsible for the ongoing stability of BOSH resources. There are usually two layers of BOSH which people take responsibility for, although sometimes the responsibility for both roles may be shared within a single team.


### Deployment Operator

A deployment operator is interested in telling the director to make sure it deploys and runs software they need on the cloud. They will want to understand...

 * How the release software should be configured;
 * What other components are involved to successful operate their software;
 * What availability zones and networks are available to them for their deployment.


### Director Operator

A director operator is interested in configuring and maintaining the director to ensure deployment operators are able to deploy their services to the cloud. They will want to understand...

 * What the general director architecture and components look like.
 * How to securely configure director components.
 * What clouds are available...
    * How to connect and authenticate to clouds with CPIs.
    * How networks are connected.
 * Authorization and authentication control...
    * How teams and users connect to the director.
    * How deployments will be accessible to others.


### Cloud Operator

A cloud operator is responsible for planning and managing the underlying infrastructure where resources are managed. They will want to understand...

 * How to plan for resource consumption...
    * What compute, memory, disk resources are being used and needed.
    * What network assignments should be allocated.
 * How to provision access to the environment.
 * How to monitor the infrastructure to identify issues which may impact availability of higher layers.

Some examples of Cloud Operators are...

 * OpenStack or vSphere environments are often managed by a dedicated infrastructure team.
 * Public clouds like Google Cloud Platform or Amazon Web Services may have a team responsible for overseeing general usage and defining policies for teams.


## Developer

A developer is interested in enhancing functionality of one or more components of BOSH. There are several different projects a developer may be interested in.


### Internal Developer

An internal developer is focused on improving or expanding the feature sets of the core BOSH components. There are several components in the core ecosystem, but in general they will want to understand...

 * Scope of features within specific BOSH components.
 * API and dependencies between the components of BOSH.
 * Teams currently responsible for components, and repositories where ongoing work can be tracked and discussed.

Some examples of Internal Developers are...

 * BOSH team - comprised of Cloud Foundry Foundation members, the teams work from around the world on different features.
 * OSS Community members - those who send pull requests and contributions to the various projects.


### CPI Developer

A CPI Developer is primarily interested in seeing support for a particular IaaS (like Amazon Web Services and Google Cloud Platform) within BOSH. They will want to understand...

 * The API exposed by the director for management of IaaS resources, such as disks and virtual machines.
 * The APIs exposed by the IaaS for managing resources.
 * Conventions encouraged and enforced by the IaaS around...
    * Disaster recovery and failure scenarios.
    * Permissions and access control.

Some examples of CPI Developers are...

 * VMware team managing [cloudfoundry-incubator/bosh-vsphere-cpi-release](https://github.com/cloudfoundry-incubator/bosh-vsphere-cpi-release)
 * SAP team managing [cloudfoundry-incubator/bosh-openstack-cpi-release](https://github.com/cloudfoundry-incubator/bosh-openstack-cpi-release)
