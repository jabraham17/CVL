#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

(cd $PROJECT_DIR && set -x && \
  mason test --show --keep-binary -- \
    $@ \
    $(./compile.py --arch-compopts --sleef) \
  | tee $PROJECT_DIR/test.log \
)

# check the last line of test.log, if it starts with OK, then the test passed
# this is required because mason exits with 1 if a test is skipped
if [[ "$(tail -n 1 $PROJECT_DIR/test.log)" == "OK"* ]]; then
  exit 0
else
  exit 1
fi
