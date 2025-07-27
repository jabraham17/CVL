#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

python3 -m tox -c $PROJECT_DIR/util/tox.ini \
  --workdir $PROJECT_DIR/.tox \
  --root $PROJECT_DIR $@ || exit 1
