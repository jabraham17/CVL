#!/usr/bin/env bash

FILE_DIR=$(cd $(dirname $0); pwd)

(set -x && chplcheck --add-rules $FILE_DIR/lint/rules.py src/*.chpl \
  --disable-rule IncorrectIndentation \
  $@ \
)
