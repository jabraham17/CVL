#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

CVL_OPTIONS=$($PROJECT_DIR/compile.py --arch-compopts --sleef)
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to determine CVL options."
  exit 1
fi

# Set MAX_LOCALES if specified in environment
rm -f $PROJECT_DIR/.MAX_LOCALES
if [[ ! -z "$MAX_LOCALES" ]]; then
  echo "$MAX_LOCALES" > $PROJECT_DIR/.MAX_LOCALES
fi

# --setComm works around a mason bug where it always defaults to `none`
(cd $PROJECT_DIR && set -x && \
  mason test --show --keep-binary \
    --setComm=$($(chpl --print-chpl-home)/util/chplenv/chpl_comm.py) \
    -- \
    $@ \
    $CVL_OPTIONS \
    --set CVL.implementationWarnings=false \
  | tee $PROJECT_DIR/test.log \
)

rm -f $PROJECT_DIR/.MAX_LOCALES

# check the last line of test.log, if it starts with OK, then the test passed
# this is required because mason exits with 1 if a test is skipped
if [[ "$(tail -n 1 $PROJECT_DIR/test.log)" == "OK"* ]]; then
  exit 0
else
  exit 1
fi
