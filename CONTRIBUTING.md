# Contributing to Greenplum Database Package for Debian

The Greenplum DB for Debian project team welcomes contributions from the
community.

If you wish to contribute code, but you have not signed our [contributor
license agreement (CLA)](https://cla.vmware.com/cla/1/preview), our bot will
update the issue when you open a Pull Request. For any questions about the CLA
process, please refer to our [FAQ](https://cla.vmware.com/faq).

## Structure of the Project

* envrc.example - environment variables that you will want to have set when
  working in the project
* gpdb - the packaging tree; this directory should only contain one directory
  named debian
  * debian - Debian packaging directory

## Helpful Links

* [Guide for Debian Maintainers][0]
  * [Debian New Maintainers' Guide][1] is an older version of the previous
    guide but may still provide helpful information

[0]: https://www.debian.org/doc/manuals/debmake-doc/index.en.html
[1]: https://www.debian.org/doc/manuals/maint-guide/

## How to Build A Package for a New Upstream GPDB Version

```sh
cd gpdb
uscan
dch --newversion <new-upstream-version> ""
origtargz
sbuild [--dist=<target-distribution>]
```

## How to Add a New Debian Patch

**Note:** Generally these patches should be used for making Greenplum DB into a
proper Debian package and _not_ for fixing bugs in upstream Greenplum DB.

```sh
cd gpdb

# start with a clean source tree
origtargz --clean
origtargz

# apply any existing patches
quilt push -a

# create a new patch
quilt new <new-patch-name>

# add a file to the patch *before* editing it
quilt add <filename>

# edit the source files that you have added to the patch

# update the patch with changes
quilt refresh

# add a description to the header
quilt header --dep3 -e

# finish editing, unapplying all patches, and leaving the source in the
# downloaded condition
quilt pop -a
```

## How to Update an Existing Debian Patch

```sh
cd gpdb

# start with a clean source tree
origtargz --clean
origtargz

# edit an existing patch
quilt push <patch-name>

# edit the source, adding any newly edited files to the patch

# update the patch with changes
quilt refresh

# return the source to the downloaded condition
quilt pop -a
```

## Appendix

These sections document one-time setup instructions.

### Setting Up `sbuild`

This section is based on [Debian Wiki - sbuild](https://wiki.debian.org/sbuild)

```sh
sudo apt install sbuild schroot debootstrap apt-cacher-ng devscripts piuparts
sudo tee ~/.sbuildrc << EOF
##############################################################################
# PACKAGE BUILD RELATED (additionally produce _source.changes)
##############################################################################
# -d
$distribution = 'unstable';
# -A
$build_arch_all = 1;
# -s
$build_source = 1;
# --source-only-changes (applicable for dput. irrelevant for dgit push-source).
$source_only_changes = 1;
# -v
$verbose = 1;
# parallel build
$ENV{'DEB_BUILD_OPTIONS'} = 'parallel=5';
##############################################################################
# POST-BUILD RELATED (turn off functionality by setting variables to 0)
##############################################################################
$run_lintian = 1;
$lintian_opts = ['-i', '-I'];
$run_piuparts = 1;
$piuparts_opts = ['--schroot', 'unstable-amd64-sbuild', '--no-eatmydata'];
$run_autopkgtest = 1;
$autopkgtest_root_args = '';
$autopkgtest_opts = [ '--', 'schroot', '%r-%a-sbuild' ];

##############################################################################
# PERL MAGIC
##############################################################################
1;
EOF
sudo sbuild-adduser $LOGNAME
sudo ln -sf ~/.sbuildrc /root/.sbuildrc

newgrp sbuild

# create chroot for Debian unstable (sid) suite
sudo sbuild-createchroot --include=eatmydata,ccache unstable \
    /srv/chroot/unstable-amd64-sbuild \
    http://127.0.0.1:3142/ftp.us.debian.org/debian
```

### Setting Up `quilt`

This section is based on [Debian Wiki - Using Quilt][quilt]

Create a `~/.quiltrc` file with the following content

```sh
QUILT_PATCHES=debian/patches
QUILT_NO_DIFF_INDEX=1
QUILT_NO_DIFF_TIMESTAMPS=1
QUILT_REFRESH_ARGS="-p ab"
# If you want some color when using `quilt diff`
QUILT_DIFF_ARGS="--color=auto"
QUILT_PATCH_OPTS="--reject-format=unified"
QUILT_COLORS="diff_hdr=1;32:diff_add=1;34:diff_rem=1;31:diff_hunk=1;33:diff_ctx=35:diff_cctx=33"
```

You can also set these as environment variables.

[quilt]: https://wiki.debian.org/UsingQuilt
