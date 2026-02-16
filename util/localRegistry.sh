#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

REG=$PROJECT_DIR/.registry
if [[ ! -d $REG ]]; then
  (cd $PROJECT_DIR && mason publish --create-registry $REG && mason publish $REG)
else
  (cd $PROJECT_DIR && mason publish $REG)
fi

export MASON_REGISTRY="local-registry|$REG"
