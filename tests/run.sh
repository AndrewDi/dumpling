#!/bin/sh

# To avoid permission denied error, please run `chmod +x tests/_utils/*`.

set -e

DUMPLING_TEST_DIR=${DUMPLING_TEST_DIR:-"/tmp/dumpling_test_result"}
DUMPLING_TEST_USER=${DUMPLING_TEST_USER:-"root"}
DUMPLING_TEST_HOST=${DUMPLING_TEST_HOST:-"127.0.0.1"}
DUMPLING_TEST_PORT=${DUMPLING_TEST_PORT:-"3306"}
DUMPLING_TEST_PASSWORD=${DUMPLING_TEST_PASSWORD:-""}

export DUMPLING_TEST_DIR
export DUMPLING_TEST_USER
export DUMPLING_TEST_HOST
export DUMPLING_TEST_PORT
export DUMPLING_TEST_PASSWORD

set -eu

mkdir -p "$DUMPLING_TEST_DIR"
PATH="tests/_utils:$PATH"
. "tests/_utils/run_services"


file_should_exist bin/tidb-server
file_should_exist bin/tidb-lightning
file_should_exist bin/dumpling
file_should_exist bin/sync_diff_inspector

trap stop_services EXIT
start_services

for script in tests/*/run.sh; do
    echo "****************** Running test $script..."
    DUMPLING_BASE_NAME="$(dirname "$script")"
    export DUMPLING_BASE_NAME
    TEST_NAME="$(basename "$(dirname "$script")")"
    DUMPLING_OUTPUT_DIR="$DUMPLING_TEST_DIR"/sql_res."$TEST_NAME"
    export DUMPLING_OUTPUT_DIR

    PATH="tests/_utils:$PATH" \
    sh "$script"

    echo "Cleaning up test output dir: $DUMPLING_OUTPUT_DIR"
    rm -rf "$DUMPLING_OUTPUT_DIR"

done

echo "Passed integration tests."
