#!/bin/bash
set -u

echo "BEGIN: igniteEnvironment.sh"

script=$(readlink -f "$0")
scriptdir=$(dirname "$script")

source $scriptdir/parseDotEnv.sh

pushd ${WORKSPACE_ROOT}

echo "Step 1/6: Reset environment"
rm -rf config
rm -rf .build/bin
rm -rf .build/public
rm -rf .build/vendor
rm -rf var

mkdir -vp .build/public
mkdir -vp var/log/


if [ "${TYPO3_INSTALL_DB_DRIVER}" == "mysqli" ]; then
  echo "Using MySQL/MariaDB as database - resetting database"
  # Drop all database tables
  mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --silent --skip-column-names -e "SHOW TABLES" ${TYPO3_INSTALL_DB_DBNAME} | \
      xargs -I% echo 'SET FOREIGN_KEY_CHECKS = 0; DROP TABLE %; SET FOREIGN_KEY_CHECKS = 1;' | \
      mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} -v ${TYPO3_INSTALL_DB_DBNAME}

    mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --init-command='USE '${TYPO3_INSTALL_DB_DBNAME} < .devcontainer/docker/db/initdb/2_create_procedure.sql
fi

if [ -f ${WORKSPACE_ROOT}/composer.json ]; then
  echo "Step 2/6: initializeTYPO3.sh"
  chmod +x .devcontainer/docker/initializeTYPO3.sh
  .devcontainer/docker/initializeTYPO3.sh

  echo "Step 3/6: Composer up"
  composer up

  if [ ! -f config/system/additional.php ]; then
    echo "Step 4/6: Add additional.php if not exists"
    cp .devcontainer/docker/typo3/additional.php config/system/additional.php
  else
    echo "Step 4/6: additional.php already exists - skipping"
  fi

  if [ "${TYPO3_INSTALL_DB_DRIVER}" == "mysqli" ]; then
    echo "Step 5/6: Fix TYPO3 image references"
    mysql -h127.0.0.1 -P3306 -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} -e 'use '${TYPO3_INSTALL_DB_DBNAME}'; call fixImgInTtContent();'
  else
    echo "Step 5/6: Fix TYPO3 image references - skipping as database driver is not mysqli"
  fi

  if [ "${COMPOSE_PROFILES}" == "php-fpm" ]; then
    echo "Step 6/6: Checking for running php-fpm"
    .devcontainer/php-fpm/server.sh restart
  elif [ "${COMPOSE_PROFILES}" == "apache" ]; then
    echo "Step 6/6: Restarting Apache"
    .devcontainer/php-fpm/server.sh
  elif [ "${COMPOSE_PROFILES}" == "frankenphp" ]; then
    echo "Step 6/6: Restarting FrankenPHP"
    .devcontainer/docker/frankenphp/server.sh restart
  fi

else
  echo "No composer.json found - skipping initializeTYPO3.sh and composer up"
fi

echo "END: igniteEnvironment.sh"
popd
