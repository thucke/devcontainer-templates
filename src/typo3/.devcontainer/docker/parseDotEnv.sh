#!/bin/bash
# parse .env file of the current project
# the convention is that this file should reside in the parent dir of the project
# having the same name as the project dir extended by '.env'
#
# !!!! IMPORTANT: WORKSPACE_ROOT has to be set before sourcing this script
set +u
# quit if env vars have been already set
[ -n "${TYPO3_INSTALL_DB_DRIVER}" ] && echo ".env alread set" && return 0
set -u

dotEnvFile="$(dirname $WORKSPACE_ROOT)/TYPO3.env"

# check if env file exists - if not copy default from .devcontainer
if [ ! -f ${dotEnvFile} ]; then
	echo "${dotEnvFile} file not found - copying default from DEV"
	cp -fv ${WORKSPACE_ROOT}/.devcontainer/docker/typo3/TYPO3.env.tmpl ${dotEnvFile}
fi

# parse .env file
if [ -f $dotEnvFile ]; then
	echo "Parsing .env file $dotEnvFile"
	export $(cat $dotEnvFile | grep -v -E "^\s*#.*$|^\s*$|#.*$" | xargs)
else
	echo "Skipping .env file $dotEnvFile"
fi

if [[ ${DB_SERVER_TYPE} =~ (mysql|mariadb) ]]; then
  export TYPO3_INSTALL_DB_DRIVER="mysqli"
  export TYPO3_INSTALL_DB_DBNAME="${MYSQLI_DBNAME}"
elif [ "${DB_SERVER_TYPE}" == "sqlite" ]; then
  export TYPO3_INSTALL_DB_DRIVER="pdo_sqlite"
  export TYPO3_INSTALL_DB_DBNAME="${SQLITE_DBFILE_PATH}"
fi
