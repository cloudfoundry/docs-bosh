A package is a component of a BOSH release that contains a packaging `spec` file and a packaging script.
Each package also references source code or pre-compiled software that you store in the `src` directory of a BOSH [release  
directory](create-release.md).

You build BOSH packages in a BOSH release directory. Your release might contain one or more packages.
This topic describes how to create a BOSH package that includes either source code or pre-compiled software.

The information and procedures in this topic form [Step 3: Create Package Skeletons](create-release.md#pkg-skeletons) of the Creating a Release topic. Refer to that topic to understand where BOSH packaging fits in the context of creating a BOSH release.

## Prerequisite {: #prerequisite }

Create a release directory. Refer to the [Create a Release Directory](create-release.md#release-dir) section in the Creating
a BOSH Release topic.

## Edit a Package Spec {: #edit-a-package-spec }

You specify package contents in the package `spec` file. BOSH automatically creates this file as a template with the following
sections when you run the `bosh generate-package PACKAGE_NAME` command:

 * `name`: Defines the package name.
 * `dependencies`: **(Optional)** Defines a list of other packages that this package depends on.
 * `files`: Defines a list of files that this package contains. You can define this list explicitly or through pattern-matching.  

To edit a package spec file:

1. Identify all compile-time dependencies.
    A compile-time dependency occurs when a package depends on another package.
	For more information, refer to the [Make  Dependency Graphs](create-release.md#graph) section of the Creating a BOSH
Release topic.
1. Run `bosh generate-package PACKAGE_NAME` for each compile-time dependency.
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

```yaml
name: ruby_1.9.3

dependencies:
- libyaml_0.1.4

files:
- ruby_1.9.3/ruby-1.9.3-p484.tar.gz
- ruby_1.9.3/rubygems-1.8.24.tgz
- ruby_1.9.3/bundler-1.2.1.gem
```


## Create a Packaging Script {: #create-a-packaging-script }

BOSH automatically creates a packaging script file template when you run the `bosh generate-package PACKAGE_NAME` command. Each
packaging script in a package must include a symlink in the format `/var/vcap/packages/<package name>` for each dependency and
deliver all compiled code to `BOSH_INSTALL_TARGET`. Store the script in the `packages/<package name>/packaging` directory.

!!! note
    If your package contains source code, the script must compile the code and deliver it to `BOSH_INSTALL_TARGET`. If your package contains pre-compiled software, the script must extract the binary from the compressed file and copy it to `BOSH_INSTALL_TARGET`.

!!! note
    If your package contains pre-compiled software, record the operating system that the pre-compiled software requires. Because a pre-compiled binary runs only on a specific operating system, any deployment using a package containing pre-compiled software requires a stemcell that contains that operating system.

Example Ruby packaging script:

```shell
set -e -x

tar xzf ruby_1.9.3/ruby-1.9.3-p484.tar.gz
pushd ruby-1.9.3-p484
  ./configure \
   --prefix=${BOSH_INSTALL_TARGET} \
   --disable-install-doc \
   --with-opt-dir=/var/vcap/packages/libyaml_0.1.4

   make
   make install
popd

tar zxvf ruby_1.9.3/rubygems-1.8.24.tgz
pushd rubygems-1.8.24
  ${BOSH_INSTALL_TARGET}/bin/ruby setup.rb
popd

${BOSH_INSTALL_TARGET}/bin/gem install ruby_1.9.3/bundler-1.2.1.gem --no-ri --no-rdoc
```

Example script referencing pre-compiled code:

```shell
tar zxf myfile.tar.gz
cp -a myfile ${BOSH_INSTALL_TARGET}
```
