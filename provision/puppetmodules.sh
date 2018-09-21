#!/bin/bash

#---------------------------------------------------------------------
# Variables
#---------------------------------------------------------------------

CODE_PATH=/etc/puppetlabs/code
ENV_PATH=environments/production

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------

function provision_from_puppetfile {

    # Create symlink for site.pp
    ln -sfT /opt/himlar/manifests/site.pp $CODE_PATH/$ENV_PATH/manifests/site.pp

    # Remove old hieradata
    rm -rf $CODE_PATH/$ENV_PATH/hieradata

    # Create symlink for hieradata
    ln -sfT /opt/himlar/hieradata $CODE_PATH/$ENV_PATH/hieradata
    ln -sfT /opt/himlar/hiera.yaml $CODE_PATH/$ENV_PATH/hiera.yaml

    # Set environment variables for Puppet
    export PUPPETFILE=/opt/himlar/Puppetfile
    export PUPPETFILE_DIR=$CODE_PATH/modules

    # Use r10k to purge obsolete modules and install/update
    cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile purge
    cd /opt/himlar && /usr/local/bin/r10k --verbose 4 puppetfile install

    # Link in profile module after running r10k
    ln -sf /opt/himlar/profile $CODE_PATH/modules/

    return 0
}

function override_modules {

    # remove modules that exists in /opt/himlar/modules
    for m in $opt_himlar_modules; do
	echo "WARNING: Module $m overrides Puppetfile"
	rm -rf $CODE_PATH/$(echo ${m#/opt/himlar/}) 2>/dev/null
    done

    return 0
}

#=====================================================================
# MAIN PROGRAM
#=====================================================================

# Find modules that exist in code path or /opt/himlar
etc_puppet_modules="$(ls -d $CODE_PATH/modules/*/ 2>/dev/null)"
opt_himlar_modules="$(ls -d /opt/himlar/modules/*/ 2>/dev/null)"

# Source command line options as env vars
while [ $# -gt 0 ]; do
    case $1 in
	HIMLAR_*=*|FACTER_*=*)
	    export $1
	    shift
	    ;;
	*)
	    # unknown
	    shift
	    ;;
    esac
done

# Default value is to NOT provision from Puppetfile
# We provison Puppetfile if /etc/puppet/modules is empty, if HIMLAR_PUPPETFILE
# is set to 'deploy' or if puppetmodules.sh is given the 'deploy' parameter
if [ -z "$etc_puppet_modules" ] || [ $HIMLAR_PUPPETFILE == "deploy" ]; then
    provision_from_puppetfile
fi

# If /opt/himlar/modules contains a module deployed via rsync, use that instead
# of the one in /etc/puppet/modules
[ -z "$opt_himlar_modules" ] || override_modules
