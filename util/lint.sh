#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

set -e

(set -x && chplcheck -c $PROJECT_DIR/Mason.toml $@)

(set -x && $PROJECT_DIR/lint/EverythingTested.py)

(set -x && $PROJECT_DIR/lint/OperatorsUpToDate.sh)
