#!/bin/bash

echo "BEGIN: server.sh (frankenphp)"

if [[ ! ${COMPOSE_PROFILES} == "frankenphp" ]]; then
  echo "server.sh: No frankenphp environment"
  exit 0
fi

if [[ "$1" == "restart" ]]; then
  echo "server.sh: Checking for running frankenphp"
  if [ $(pidof frankenphp| wc -w) -ne 0 ]; then
    echo "restartFrankenphp: Stopping running frankenphp"
    pidof frankenphp | xargs kill -9
    sleep 1
  fi
fi

if [ $(pidof frankenphp| wc -w) -eq 0 ]; then
  echo "server.sh: Starting frankenphp in daemon mode"
  nohup frankenphp run --config ${WORKSPACE_ROOT}/.devcontainer/docker/typo3/typo3.caddyfile >/dev/null 2>&1 &
  #nohup frankenphp run --config ${WORKSPACE_ROOT}/.devcontainer/docker/typo3/typo3.caddyfile >>${WORKSPACE_ROOT}/frankenphp.log 2>&1 &
  echo "Devcontainer: frankenphp server started (PID: $!))"
else
  echo "Devcontainer: frankenphp server already running (PID: $(pidof frankenphp))"
fi

echo "END: server.sh (frankenphp)"
exit 0
