---
title: Creating BOSH Packages
---

A BOSH package is a component of a BOSH release that contains a packaging `spec` file and a packaging script. 
Each package also references source code or pre-compiled software that you store in the `src` directory of a BOSH [release  
directory](./create-release.html).

You build BOSH packages in a BOSH release directory. Your release might contain one or more packages.
This topic describes how to create a BOSH package that includes either source code or pre-compiled software. 

The information and procedures in this topic form [Step 3: Create Package Skeletons](./create-release.html#pkg-skeletons) of the Creating a Release topic. Refer to that topic to understand where BOSH packaging fits in the context of creating a BOSH release.

## <a id="prerequisite"></a>Prerequisite ##

Create a release directory. Refer to the [Create a Release Directory](./create-release.html#release-dir) section in the Creating 
a BOSH Release topic. 

## <a id="edit-a-package-spec"></a>Edit a Package Spec ##

You specify package contents in the package `spec` file. BOSH automatically creates this file as a template with the following 
sections when you run the `bosh generate package PACKAGE_NAME` command:

 * `name`: Defines the package name.
 * `dependencies`: **(Optional)** Defines a list of other packages that this package depends on.
 * `files`: Defines a list of files that this package contains. You can define this list explicitly or through pattern-matching.  

To edit a package spec file:

1. Identify all compile-time dependencies.
    A compile-time dependency occurs when a package depends on another package. 
	For more information, refer to the [Make  Dependency Graphs](./create-release.html#graph) section of the Creating a BOSH 
Release topic.
1. Run `bosh generate package PACKAGE_NAME` for each compile-time dependency. 
1. Copy all files that the package requires to the `src` directory of the BOSH release directory.

    Typically, these files are source code. If you are including pre-compiled software, copy a compressed file that contains the 
pre-compiled binary.

1. Edit each package spec file as follows:
    * Add the names of the files for that package.
    * Add the names of any compile-time dependencies to each package spec file. Use `[]` to indicate an empty array if a package 
has no compile-time dependencies.

    The example shows an edited Ruby spec file with dependencies and file names. 
    Ruby 1.9.3 has a compile-time dependency on libyaml\_0.1.4, and the ruby\_1.9.3 source code consists of three files.

	
    Example Ruby package spec file:

<pre class='code'>
  name: ruby&#95;1.9.3

  dependencies:
  - libyaml&#95;0.1.4

  files:
  - ruby&#95;1.9.3/ruby-1.9.3-p484.tar.gz
  - ruby&#95;1.9.3/rubygems-1.8.24.tgz
  - ruby&#95;1.9.3/bundler-1.2.1.gem
</pre>
	 
	 
## <a id="create-a-packaging-script"></a>Create a Packaging Script ##

BOSH automatically creates a packaging script file template when you run the `bosh generate package PACKAGE_NAME` command. Each 
packaging script in a package must include a symlink in the format `/var/vcap/packages/<package name>` for each dependency and 
deliver all compiled code to `BOSH_INSTALL_TARGET`. Store the script in the `packages/<package name>/packaging` directory.

  <p class="note"><strong>Note</strong>: If your package contains source code, the script must compile the code and deliver it to 
<code>BOSH&#95;INSTALL&#95;TARGET</code>. If your package contains pre-compiled software, the script must extract the binary from the compressed file and copy it to <code>BOSH&#95;INSTALL&#95;TARGET</code>.

  <p class="note"><strong>Note</strong>: If your package contains pre-compiled software, record the operating system that the pre-compiled software requires. Because a pre-compiled binary runs only on a specific operating system, any deployment using a package containing pre-compiled software requires a stemcell that contains that operating system.</p> 

Example Ruby packaging script:

<pre class='code'>
set -e -x

tar xzf ruby&#95;1.9.3/ruby-1.9.3-p484.tar.gz
pushd ruby-1.9.3-p484
  ./configure \
   --prefix=${BOSH&#95;INSTALL&#95;TARGET} \
   --disable-install-doc \
   --with-opt-dir=/var/vcap/packages/libyaml&#95;0.1.4

   make
   make install
popd

tar zxvf ruby&#95;1.9.3/rubygems-1.8.24.tgz
pushd rubygems-1.8.24
  ${BOSH&#95;INSTALL&#95;TARGET}/bin/ruby setup.rb
popd

${BOSH&#95;INSTALL&#95;TARGET}/bin/gem install ruby&#95;1.9.3/bundler-1.2.1.gem --no-ri --no-rdoc
</pre>


    
Example script referencing pre-compiled code:
<pre class='code'>
tar zxf myfile.tar.gz
cp -a myfile ${BOSH&#95;INSTALL&#95;TARGET}
</pre>