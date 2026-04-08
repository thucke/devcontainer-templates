#!/bin/bash
set -eu

# post start script
echo "BEGIN: postAttachCommandScript.sh"
.devcontainer/docker/frankenphp/server.sh
echo "END: postAttachCommandScript.sh"
echo ""
echo "===================================================================================="
echo "Enjoy using this TYPO3 devcontainer template"
echo "You can close this terminal without doubts if you don't need it for other activities"
echo "===================================================================================="
