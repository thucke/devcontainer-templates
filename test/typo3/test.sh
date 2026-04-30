#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "distro" lsb_release -c
check "Testing git command existence" test -n  $(which git)
check "Testing docker command existence" test -n  $(which docker)

if [ "${DB_SERVER_TYPE}" != "sqlite" ]; then
    check "Testing docker compose project ${COMPOSE_PROJECT_NAME} existence" \
        test $(docker compose ls --quiet |grep -c $COMPOSE_PROJECT_NAME) -eq 1

    check "Testing docker compose project database health for ${DB_SERVER_TYPE}" \
        test $(docker ps --filter "label=dev.containers.servicetype=database" | \
                grep $COMPOSE_PROJECT_NAME | \
                grep -c healthy) == 1
fi

# TODO: Add a test for webserver connectivity on port 80 once we have a sample project that includes a webserver and a healthcheck for it.
# Apache DOCuMNT_ROOT and log location must depend on a variable:
# WORKSPACE_ROOT for normal processing and GITHUB_WORKSPACE for github actions.
check "Testing docker compose project webserver conectivity on port 80" \
    test $(nc -w 3 -z localhost 80 1>&2 2>/dev/null; echo $?) -eq 0

# Report result
reportResults