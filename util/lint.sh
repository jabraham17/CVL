#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

set -e

(set -x && chplcheck -c $PROJECT_DIR/Mason.toml $@)

