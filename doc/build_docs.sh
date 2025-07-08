#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

(cd $PROJECT_DIR && set -x && rm -rf build && mkdir build)

# generate the documentation source files
(cd $PROJECT_DIR && set -x && \
  chpldoc src/CVL.chpl --process-used-modules \
  $(./compile.py --docopts) \
  --save-sphinx build/doc --print-commands --no-html -o dummy  \
)

# delete everything in build/doc/source except for the modules
(cd $PROJECT_DIR && set -x && \
  find build/doc/source -mindepth 1 -maxdepth 1 ! -name 'modules' -exec rm -rf {} + \
)
# move the modules/src directory to the correct location
(cd $PROJECT_DIR && set -x && \
  mv build/doc/source/modules/src/* build/doc/source/ && \
  rmdir build/doc/source/modules/src && \
  rmdir build/doc/source/modules \
)

# copy in the correct index file
(cd $PROJECT_DIR && set -x && \
  cp doc/index.rst build/doc/source/index.rst \
)

# build the documentation
(cd $PROJECT_DIR && set -x && \
  python3 $(chpl --print-chpl-home)/third-party/chpl-venv/install/chpldeps \
  sphinx-build -W -n -c doc -b html \
    -d build/doc/build/doctrees build/doc/source build/doc/html \
)
