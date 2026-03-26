#!/bin/bash
set -eu

# post start script
echo "BEGIN: initializeTYPO3.sh"

echo "initializeTYPO3: Checking if site already has been initialized"
if test ! -d .build/vendor; then
  echo "initializeTYPO3: Initialize TYPO3"
  composer require --dev "helhum/dotenv-connector": "*", "helhum/typo3-console": "*"
  composer config allow-plugins.helhum/dotenv-connector true
  composer config bin-dir .build/bin
  composer config vendor-dir .build/vendor
  composer config extra.typo3/cms.web-dir .build/public
  composer config extra.helhum/dotenv-connector.env-file TYPO3.env
  composer install
  # Add .build/bin to PATH
  [[ ":$PATH:" != *":${WORKSPACE_ROOT}/.build/bin:"* ]] && export PATH="${WORKSPACE_ROOT}/.build/bin:${PATH}"
fi

typo3_major_version=$(typo3 -V|grep "TYPO3 CMS"|perl -n -e '/\ ([\d]+)/ && print $1')
echo "initializeTYPO3: Running on TYPO3 major version ${typo3_major_version}"

echo "initializeTYPO3: DB compare"
typo3 database:updateschema --no-interaction --no-ansi || true

echo "initializeTYPO3: Update reference index"
typo3 referenceindex:update --no-interaction --no-ansi || true

#echo "initializeTYPO3: Create new backend user"
#$typo3_cli backend:createadmin ${TYPO3_INSTALL_ADMIN_USER} ${TYPO3_INSTALL_ADMIN_PASSWORD} --no-interaction --no-ansi || true

# take care of file ownership esp. to support cross container functionality
echo "initializeTYPO3: Update file and directory ownership"
chown -R ${DEVCONTAINER_SERVICE_NAME}:${DEVCONTAINER_SERVICE_NAME} config .build var
chgrp ${DEVCONTAINER_SERVICE_NAME} ${WORKSPACE_ROOT}

# needed as directory check moans about wrong permissions
echo "initializeTYPO3: Update file permissions"
chmod -R 2770 .build config var

echo "END: initializeTYPO3.sh"
