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
    mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --silent --skip-column-names -e "SHOW TABLES" ${TYPO3_INSTALL_DB_DBNAME} |
        xargs -L1 -I% echo 'SET FOREIGN_KEY_CHECKS = 0; DROP TABLE %; SET FOREIGN_KEY_CHECKS = 1;' |
        mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} -v ${TYPO3_INSTALL_DB_DBNAME}

    mysql -h${TYPO3_INSTALL_DB_HOST} -P${TYPO3_INSTALL_DB_PORT} -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} --init-command='USE '${TYPO3_INSTALL_DB_DBNAME} < .devcontainer/docker/db/initdb/2_create_procedure.sql
fi

echo "Step 2/6: postStart.sh"
chmod +x .devcontainer/docker/postStart.sh
.devcontainer/docker/postStart.sh

echo "Step 3/6: Composer up"
composer up

echo "Step 4/6: Add additional.php if not exists"
[ ! -f config/system/additional.php ] && cp .devcontainer/docker/typo3/additional.php config/system/additional.php

echo "Step 5/6: Fix TYPO3 image references"
mysql -h127.0.0.1 -P3306 -u${TYPO3_INSTALL_DB_USER} -p${TYPO3_INSTALL_DB_PASSWORD} -e 'use '${TYPO3_INSTALL_DB_DBNAME}'; call fixImgInTtContent();'

if [[ "${COMPOSE_PROFILES}" =~ "php-fpm" ]]; then
  echo "Step 6/6: Checking for running php-fpm"
  .devcontainer/php-fpm/server.sh restart
elif [[ "${COMPOSE_PROFILES}" =~ "apache" ]]; then
  echo "Step 6/6: Restarting Apache"
  .devcontainer/php-fpm/server.sh
elif [[ "${COMPOSE_PROFILES}" =~ "frankenphp" ]]; then
  echo "Step 6/6: Restarting FrankenPHP"
  .devcontainer/docker/frankenphp/server.sh restart
fi

echo "END: igniteEnvironment.sh"
popd
