#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

(set -x && chplcheck --add-rules $PROJECT_DIR/lint/rules.py src/*.chpl \
  --disable-rule IncorrectIndentation \
  $@ \
)
