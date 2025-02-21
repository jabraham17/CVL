#!/usr/bin/env bash

FILE_DIR=$(cd $(dirname $0); pwd)

(cd $FILE_DIR && set -x && \
  mason test --show -- $@ $(./compile.py --arch-compopts))
