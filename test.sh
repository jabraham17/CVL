#!/usr/bin/env bash

FILE_DIR=$(cd $(dirname $0); pwd)

(cd $FILE_DIR && set -x && \
  mason test --show -- \
    $@ \
    $(./compile.py --arch-compopts) \
  | tee $FILE_DIR/test.log \
)

# check the last line of test.log, if it starts with OK, then the test passed
# this is required because mason exits with 1 if a test is skipped
if [[ "$(tail -n 1 $FILE_DIR/test.log)" == "OK"* ]]; then
  exit 0
else
  exit 1
fi
