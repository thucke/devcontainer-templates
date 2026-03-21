#!/bin/bash
set -eu

# post start script
echo "BEGIN: postAttachCommandScript.sh"
.devcontainer/docker/frankenphp/server.sh
echo "END: postAttachCommandScript.sh"
