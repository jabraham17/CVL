#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

CVL_OPTIONS=$($PROJECT_DIR/compile.py --sleef)
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to determine CVL options."
  exit 1
fi

# TODO: can't pass --arch-compopts to mason build --example, doesn't take args
# (cd $PROJECT_DIR && set -x && \
#   mason build --example \
#     $@ \
#     $CVL_OPTIONS
# )
# for now, list all *.chpl files in example/ and build them manually
mkdir -p "$PROJECT_DIR/target/example"
for example in "$PROJECT_DIR"/example/*.chpl; do
  (cd $PROJECT_DIR && set -x && \
    chpl $example -o "target/example/$(basename "${example%.*}")" $@ $CVL_OPTIONS \
  )
done

# TODO: mason run --example is borked and doesn't work yet
for example in "$PROJECT_DIR/target/example"/*; do
  if [[ "$(basename "$example")" == *_real ]]; then
    continue
  fi
  if [[ -x "$example" ]]; then
    echo "Running: $(basename "$example")"
    $example -nl1
    res=$?
    echo ""
    if [[ $res -ne 0 ]]; then
      echo "Error: Example $(basename "$example") failed with exit code $res"
      exit $res
    fi
  fi
done
