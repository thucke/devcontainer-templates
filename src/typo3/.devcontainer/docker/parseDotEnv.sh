#!/bin/bash
# parse .env file of the current project
# the convention is that this file should reside in the parent dir of the project
# having the same name as the project dir extended by '.env'

# quit if env vars have been already set
[ -n "$TYPO3_INSTALL_DB_DRIVER" ] && echo ".env alread set" && return 0

#calculate $WORKSPACE_ROOT and $dotEnvFile
if [ "$0" == "-bash" ]; then
	export WORKSPACE_ROOT="$PWD"
else
	local script=$(readlink -f "$0")
	local scriptdir=$(dirname "$script")
	export WORKSPACE_ROOT=$(dirname "$scriptdir")
fi
dotEnvFile="$(dirname $WORKSPACE_ROOT)/TYPO3.env"

# check if env file exists - if not copy default from .devcontainer
if [ ! -f ${dotEnvFile} ]; then
	echo "${dotEnvFile} file not found - copying default from DEV"
	cp -fv ${WORKSPACE_ROOT}/.devcontainer/TYPO3.env.tmpl ${dotEnvFile}
fi

# parse .env file
if [ -f $dotEnvFile ]; then
	echo "Parsing .env file $dotEnvFile"
	export $(cat $dotEnvFile | grep -v -E "^\s*#.*$|^\s*$|#.*$" | xargs)
else
	echo "Skipping .env file $dotEnvFile"
fi

