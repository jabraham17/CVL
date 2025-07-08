#!/usr/bin/env bash

set -e

CURRENT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) ; pwd)
EXAMPLE_PROJECT_DIR="${CURRENT_DIR}/ExampleProject"
BUILD_DIR="${EXAMPLE_PROJECT_DIR}/build"
INSTALL_DIR="${EXAMPLE_PROJECT_DIR}/install"

function build() {
  local cmake_cfg_args=$1
  local cmake_build_args=$2
  set -x

  mkdir -p "${BUILD_DIR}"
  cmake -B "${BUILD_DIR}" "${EXAMPLE_PROJECT_DIR}" ${cmake_cfg_args}
  cmake --build "${BUILD_DIR}" ${cmake_build_args}
  cmake --install "${BUILD_DIR}" --prefix "${INSTALL_DIR}"

  set +x
}
function run() {
  set -x

  # Check if the executable is built
  if [[ ! -f "${INSTALL_DIR}/bin/ExampleProject" ]]; then
    echo "Error: ExampleProject executable not found in ${INSTALL_DIR}/bin/"
    exit 1
  fi

  # Run the executable to ensure it works
  "${INSTALL_DIR}/bin/ExampleProject"

  set +x
}
function clean() {
  set -x
  rm -rf "${BUILD_DIR}" "${INSTALL_DIR}"
  set +x
}
function check_no_deps() {
  if [[ -d "${BUILD_DIR}/_deps" ]]; then
    echo "Error: _deps directory should not exist after build."
    exit 1
  fi
}
function check_deps() {
  if [[ ! -d "${BUILD_DIR}/_deps" ]]; then
    echo "Error: _deps directory should exist after build."
    exit 1
  fi
}

clean

#
# Test that we can pass CVL_DIR to the CMakeLists.txt
#
build "-DCVL_DIR=${CURRENT_DIR}/../../cmake" "--target ExampleProject"
run
check_no_deps
clean

#
# Test that we can pass CVL_SOURCE_DIR to the CMakeLists.txt
#
build "-DCVL_SOURCE_DIR=${CURRENT_DIR}/../.." "--target ExampleProject"
run
check_no_deps
clean

#
# Test that we can add thr package to the cmake prefix path
#
build "-DCMAKE_PREFIX_PATH=${CURRENT_DIR}/../../cmake" "--target ExampleProject"
run
check_no_deps
clean

#
# Test that we can fetch the package when it can't be found
#
build "" "--target ExampleProject"
run
check_deps
clean
