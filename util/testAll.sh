#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

$PROJECT_DIR/util/test.sh|| exit 1
$PROJECT_DIR/test/cmake/testExampleProject.sh || exit 1
