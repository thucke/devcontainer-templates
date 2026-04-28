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
                grep -c healthy) -eq 1
fi

check "Testing docker compose project webserver conectivity on port 80" \
    test $(nc -w 3 -z localhost 80) -eq 0

# Report result
reportResults