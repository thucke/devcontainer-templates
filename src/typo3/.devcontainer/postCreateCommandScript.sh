#!/bin/bash
set -eu

# post start script
echo "BEGIN: postCreateCommandScript.sh"

# check if docker containers are already running only if docker cli is installed
if [ -n `which docker` ] && [ "${TYPO3_INSTALL_DB_DRIVER:-pdo_sqlite}" != "pdo_sqlite" ]; then
  echo "postCreateCommandScript: Checking if docker containers are already running"
  if [ `docker compose ls -q --filter "name=^${COMPOSE_PROJECT_NAME}$" | wc -l` -eq 0 ]; then
    compose_filename="${WORKSPACE_ROOT}/.devcontainer/docker/docker-compose.backend.yaml"
    # start docker containers for initialization
    echo "postCreateCommandScript: Starting docker containers for ${COMPOSE_PROJECT_NAME}"
    docker compose -f ${compose_filename} up -d --wait
  else
    echo "Docker containers for ${COMPOSE_PROJECT_NAME} are already running."
  fi
fi

# ignite TYPO3 environment for the first time
echo "postCreateCommandScript: Ignite TYPO3 environment for the first time"
${WORKSPACE_ROOT}/.devcontainer/docker/igniteEnvironment.sh

echo "END: postCreateCommandScript.sh"
