---
title: What Problems Does BOSH Solve?
---

BOSH allows individual developers and teams to easily version, package and deploy software in a reproducible manner.

Any software, whether it is a simple static site or a complex multi-component service, will need to be updated and repackaged at some point. This updated software might need to be deployed to a cluster, or it might need to be packaged for end-users to deploy to their own servers. In a lot of cases, the developers who produced the software will be deploying it to their own production environment. Usually, a team will use a staging, development, or demo environment that is similarly configured to their production environment to verify that updates run as expected. These staging environments are often taxing to build and administer. Maintaining consistency between multiple environments is often painful to manage.

Developer/operator communities have come far in solving similar situations with tools like Chef, Puppet, and Docker. However, each organization solves these problems in a different way, which usually involves a variety of different, and not necessarily well-integrated, tools. While these tools exist to solve the individual parts of versioning, packaging, and deploying software reproducibly, BOSH was designed to do each of these as a whole.

BOSH was purposefully constructed to address the four principles of modern [Release Engineering](http://en.wikipedia.org/wiki/Release_engineering) in the following ways:

> **Identifiability**: Being able to identify all of the source, tools, environment, and other components that make up a particular release.

BOSH has a concept of a software release which packages up all related source code, binary assets, configuration etc. This allows users to easily track contents of a particular release. In addition to releases BOSH provides a way to capture all Operating System dependencies as one image.

> **Reproducibility**: The ability to integrate source, third party components, data, and deployment externals of a software system in order to guarantee operational stability.

BOSH tool chain provides a centralized server that manages software releases, Operating System images, persistent data, and system configuration. It provides a clear and simple way of operating a deployed system.

> **Consistency**: The mission to provide a stable framework for development, deployment, audit, and accountability for software components.

BOSH software releases workflows are used throughout the development of the software and when the system needs to be deployed. BOSH centralized server allows users to see and track changes made to the deployed system.

> **Agility**: The ongoing research into what are the repercussions of modern software engineering practices on the productivity in the software cycle, i.e. continuous integration.

BOSH tool chain integrates well with current best practices of software engineering (including Continuous Delivery) by providing ways to easily create software releases in an automated way and to update complex deployed systems with simple commands.

---
Next: [What is a Stemcell?](stemcell.html)

Previous: [What is BOSH?](about.html)
