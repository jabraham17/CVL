#!/usr/bin/env bash

FILE_DIR=$(cd $(dirname $0); pwd)


# TODO: mason doc doesn't yet let us pass in extra arguments, so manually build
# the docs for now
# (cd $FILE_DIR && set -x && \
#   mason docs \
# )
(cd $FILE_DIR && set -x && \
  chpldoc src/CVL.chpl -o doc/ --process-used-modules \
  $(./compile.py --docopts) \
)
