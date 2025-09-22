#!/usr/bin/env bash

SLEEF_DIR=$(cd $(dirname $0); pwd)

# FIXME: use 3.8, not the latest 3.9.0, because 3.8 builds faster and 3.9.0 has issues
# with the non-test build requiring gmp
SLEEF_VERSION=3.8
SLEEF_URL=https://github.com/shibatch/sleef/archive/refs/tags/${SLEEF_VERSION}.tar.gz

$SLEEF_DIR/clean.sh

# download the tarball to SLEEF_DIR
(cd $SLEEF_DIR && \
  curl -L $SLEEF_URL -o $SLEEF_VERSION.tar.gz && \
  tar xf $SLEEF_VERSION.tar.gz && rm $SLEEF_VERSION.tar.gz && \
  mv sleef-$SLEEF_VERSION sleef-src \
)

chpl_home=$(chpl --print-chpl-home)
chpl_cc=$($chpl_home/util/chplenv/chpl_compiler.py --host --cc --compiler-only)
chpl_cxx=$($chpl_home/util/chplenv/chpl_compiler.py --host --cxx --compiler-only)
chpl_cc_flags=$($chpl_home/util/chplenv/chpl_compiler.py --host --cc --additional)
chpl_cxx_flags=$($chpl_home/util/chplenv/chpl_compiler.py --host --cxx --additional)

mkdir -p $SLEEF_DIR/sleef-build
cmake -S $SLEEF_DIR/sleef-src -B $SLEEF_DIR/sleef-build/ -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$SLEEF_DIR/sleef-install \
  -DCMAKE_INSTALL_LIBDIR=$SLEEF_DIR/sleef-install/lib \
  -DSLEEF_BUILD_SHARED_LIBS=OFF -DSLEEF_BUILD_TESTS=OFF \
  -DSLEEF_SHOW_CONFIG=ON \
  -DCMAKE_C_COMPILER=$chpl_cc -DCMAKE_C_FLAGS="$chpl_cc_flags" \
  -DCMAKE_CXX_COMPILER=$chpl_cxx -DCMAKE_CXX_FLAGS="$chpl_cxx_flags"

cmake --build $SLEEF_DIR/sleef-build/ -j --clean-first
cmake --install $SLEEF_DIR/sleef-build/
