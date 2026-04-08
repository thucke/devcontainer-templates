#!/bin/bash
#
# !!!! IMPORTANT: WORKSPACE_ROOT has to be set before sourcing this script
echo "BEGIN: igniteEnvironment.sh"

typo3_major_version=$(typo3 -V|grep "TYPO3 CMS"|perl -n -e '/\ ([\d]+)/ && print $1')
echo "initializeTYPO3: Running on TYPO3 major version ${typo3_major_version}"

echo "initializeTYPO3: DB compare"
typo3 database:updateschema --no-interaction --no-ansi || true

echo "igniteEnvironment.sh: Reset environment"
rm -rfv config .build/bin .build/public .build/vendor var
mkdir -vp .build/public var/log/ var/lib
if [ "${DB_SERVER_TYPE}" == "sqlite" ]; then
  rm -fv ${SQLITE_DBFILE_PATH}
  mkdir -vp $(dirname ${SQLITE_DBFILE_PATH})
else
  echo "igniteEnvironment.sh: No need to create SqLite datafile directory"
fi

#echo "initializeTYPO3: Create new backend user"
#$typo3_cli backend:createadmin ${TYPO3_INSTALL_ADMIN_USER} ${TYPO3_INSTALL_ADMIN_PASSWORD} --no-interaction --no-ansi || true

    mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --init-command='USE '${TYPO3_INSTALL_DB_DBNAME} < .devcontainer/docker/db/initdb/2_create_procedure.sql
elif [ "${TYPO3_INSTALL_DB_DRIVER}" == "pdo_sqlite" ] && [ -f ${SQLITE_DBFILE_PATH} ]; then
  echo "Using SQLite as database - resetting database"
  rm -fv ${SQLITE_DBFILE_PATH}
fi

if [ -f ${WORKSPACE_ROOT}/composer.json ]; then
  echo "initializeTYPO3.sh: Found composer.json - running initializeTYPO3.sh"
  chmod +x .devcontainer/docker/initializeTYPO3.sh
  .devcontainer/docker/initializeTYPO3.sh
else
  echo "No composer.json found - skipping initializeTYPO3.sh and composer up"
fi

if [[ "${COMPOSE_PROFILES}" =~ "php-fpm" ]]; then
    echo "initializeTYPO3.sh: Checking for running php-fpm"
    .devcontainer/php-fpm/server.sh restart
elif [[ "${COMPOSE_PROFILES}" =~ "apache" ]]; then
    echo "initializeTYPO3.sh: Restarting Apache"
    .devcontainer/php-fpm/server.sh
elif [[ "${COMPOSE_PROFILES}" =~ "frankenphp" ]]; then
    echo "initializeTYPO3.sh: Restarting FrankenPHP"
    .devcontainer/docker/frankenphp/server.sh restart
fi

echo "END: initializeTYPO3.sh"
