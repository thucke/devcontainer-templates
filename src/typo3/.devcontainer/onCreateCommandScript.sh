#!/bin/bash
set -eu

echo "BEGIN: onCreateCommandScript.sh"

# initialize TYPO3.env if not exists
echo "onCreateCommandScript: Initializing TYPO3.env if not exists"
[ ! -f ${WORKSPACE_ROOT}/TYPO3.env ] && cp ${WORKSPACE_ROOT}/.devcontainer/docker/TYPO3.env.tmpl ${WORKSPACE_ROOT}/TYPO3.env

# configure git safe directories
echo "onCreateCommandScript: Configuring git safe directories"
git config --global --add safe.directory ${WORKSPACE_ROOT}

# make scripts executable
echo "onCreateCommandScript: Making scripts executable"
find ${WORKSPACE_ROOT}/.devcontainer -name *.sh -type f -exec chmod -c +x {} \;

echo "END: onCreateCommandScript.sh"
