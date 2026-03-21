#!/bin/bash
set -eu

# post start script
echo "BEGIN: postAttachCommandScript.sh"

cd ${WORKSPACE_ROOT}
.devcontainer/docker/frankenphp/server.sh

# check if docker containers are already running only if docker cli is installed
if [[ `which git` ]]; then
  echo "postAttachCommandScript: Checking git repository status"
  git status || grep "nothing to commit, working tree clean" > /dev/null || echo "postAttachCommandScript: Warning: git repository has uncommitted changes"
fi 

echo "END: postAttachCommandScript.sh"
