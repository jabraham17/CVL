#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

set -e

(set -x && chplcheck -c $PROJECT_DIR/Mason.toml $@)

(set -x && $PROJECT_DIR/lint/EverythingTested.py)

(set -x && $PROJECT_DIR/lint/OperatorsUpToDate.sh)

# TODO: re-enable this once docs are complete
# chpl_home=$(chpl --print-chpl-home)
# TO_CHECK=$(find src -name "*.chpl")
# (set -x && CHPL_HOME=$chpl_home $chpl_home/tools/chpldoc/findUndocumentedSymbols --ci $TO_CHECK)
