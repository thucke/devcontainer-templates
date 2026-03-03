#!/bin/bash
set -eu

# post start script
echo "BEGIN: poststart.sh"

echo "postStart: Checking if site already has been initialized"
if test ! -d .build/vendor; then
  echo "postStart: Initialize TYPO3"
  composer install
  # Add .build/bin to PATH
  [[ ":$PATH:" != *":${WORKSPACE_ROOT}/.build/bin:"* ]] && export PATH="${WORKSPACE_ROOT}/.build/bin:${PATH}"
fi

typo3_major_version=$(typo3 -V|grep "TYPO3 CMS"|perl -n -e '/\ ([\d]+)/ && print $1')
echo "postStart: Running on TYPO3 major version ${typo3_major_version}"

echo "postStart: DB compare"
typo3 database:updateschema --no-interaction --no-ansi || true

echo "postStart: Update reference index"
typo3 referenceindex:update --no-interaction --no-ansi || true

#echo "postStart: Create new backend user"
#$typo3_cli backend:createadmin ${TYPO3_INSTALL_ADMIN_USER} ${TYPO3_INSTALL_ADMIN_PASSWORD} --no-interaction --no-ansi || true

# take care of file ownership esp. to support cross container functionality
echo "postStart: Update file and directory ownership"
chown -R ${DEVCONTAINER_SERVICE_NAME}:${DEVCONTAINER_SERVICE_NAME} config .build var
chgrp ${DEVCONTAINER_SERVICE_NAME} ${WORKSPACE_ROOT}

# needed as directory check moans about wrong permissions
echo "postStart: Update file permissions"
chmod -R 2770 .build config var

echo "END: poststart.sh"
