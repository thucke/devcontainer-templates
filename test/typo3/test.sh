#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "distro" lsb_release -c
check "Testing docker command existence" test -n  $(which docker)
check "Testing git command existence" test -n  $(which git)

# Report result
reportResults