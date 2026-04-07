#!/bin/bash
#
# !!!! IMPORTANT: WORKSPACE_ROOT has to be set before sourcing this script
echo "BEGIN: igniteEnvironment.sh"

set -u
pushd ${WORKSPACE_ROOT}

source .devcontainer/docker/parseDotEnv.sh

echo "igniteEnvironment.sh: Reset environment"
rm -rfv config .build/bin .build/public .build/vendor var
mkdir -vp .build/public var/log/ var/lib/
if [ -n ${SQLITE_DBFILE_PATH} ]; then
  rm -fv ${SQLITE_DBFILE_PATH}
  mkdir -vp $(dirname ${SQLITE_DBFILE_PATH})
else
  echo "igniteEnvironment.sh: No need to create SqLite datafile directory"
fi

if [ "${TYPO3_INSTALL_DB_DRIVER}" == "mysqli" ]; then
  echo "Using MySQL/MariaDB as database - resetting database"
  # Drop all database tables
  mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --silent --skip-column-names -e "SHOW TABLES" ${TYPO3_INSTALL_DB_DBNAME} | \
      xargs -I% echo 'SET FOREIGN_KEY_CHECKS = 0; DROP TABLE %; SET FOREIGN_KEY_CHECKS = 1;' | \
      mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} -v ${TYPO3_INSTALL_DB_DBNAME}

    mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --init-command='USE '${TYPO3_INSTALL_DB_DBNAME} < .devcontainer/docker/db/initdb/2_create_procedure.sql
elif [ "${TYPO3_INSTALL_DB_DRIVER}" == "pdo_sqlite" ] && [ -f ${SQLITE_DBFILE_PATH} ]; then
  echo "Using SQLite as database - resetting database"
  rm -fv ${SQLITE_DBFILE_PATH}
fi

if [ -f ${WORKSPACE_ROOT}/composer.json ]; then
  echo "initializeTYPO3.sh: Found composer.json - running initializeTYPO3.sh"
  chmod +x .devcontainer/docker/initializeTYPO3.sh
  .devcontainer/docker/initializeTYPO3.sh

  echo "initializeTYPO3.sh: Running composer up"
  composer up

  if [ ! -f config/system/additional.php ]; then
    echo "initializeTYPO3.sh: Add additional.php if not exists"
    cp .devcontainer/docker/typo3/additional.php config/system/additional.php
  else
    echo "initializeTYPO3.sh: additional.php already exists - skipping"
  fi

  if [ "${TYPO3_INSTALL_DB_DRIVER}" == "mysqli" ]; then
    echo "initializeTYPO3.sh: Fix TYPO3 image references"
    mysql -h127.0.0.1 -P3306 -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} -e 'use '${TYPO3_INSTALL_DB_DBNAME}'; call fixImgInTtContent();'
  else
    echo "initializeTYPO3.sh: Fix TYPO3 image references - skipping as database driver is not mysqli"
  fi

  if [ "${COMPOSE_PROFILES}" == "php-fpm" ]; then
    echo "initializeTYPO3.sh: Checking for running php-fpm"
    .devcontainer/php-fpm/server.sh restart
  elif [ "${COMPOSE_PROFILES}" == "apache" ]; then
    echo "initializeTYPO3.sh: Restarting Apache"
    .devcontainer/php-fpm/server.sh
  elif [ "${COMPOSE_PROFILES}" == "frankenphp" ]; then
    echo "initializeTYPO3.sh: Restarting FrankenPHP"
    .devcontainer/docker/frankenphp/server.sh restart
  fi

else
  echo "No composer.json found - skipping initializeTYPO3.sh and composer up"
fi

echo "END: igniteEnvironment.sh"
popd
