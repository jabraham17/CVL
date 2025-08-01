#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)
set -e

# rebuild operators from Vectors.chpl, make sure it matches src/Vector/Operators.chpl
TEMP=$(mktemp -d)
(set -x && $PROJECT_DIR/util/generate_ops.py --filename $PROJECT_DIR/src/Vector.chpl --output $TEMP/Operators.chpl)
(set -x && diff -u $PROJECT_DIR/src/Vector/Operators.chpl $TEMP/Operators.chpl)
(set -x && rm -rf $TEMP)
