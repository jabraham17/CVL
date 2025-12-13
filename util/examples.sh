#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)

CVL_OPTIONS=$($PROJECT_DIR/compile.py)
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to determine CVL options."
  exit 1
fi

function build_and_run() {
  local chpl_file=$1
  local compopts=$2

  local basename=$(basename "$chpl_file" .chpl)

  echo "Compiling: $basename with options: '$compopts'"
  chpl $chpl_file -o "$PROJECT_DIR/target/example/$basename" $CVL_OPTIONS
  if [[ $? -ne 0 ]]; then
    echo "Error: Compilation of $basename failed."
    exit 1
  fi

  echo "Running: $basename"
  "$PROJECT_DIR/target/example/$basename" -nl1
  if [[ $? -ne 0 ]]; then
    echo "Error: Example $basename failed with exit code $res"
    exit $res
  fi
  echo ""
}


mkdir -p "$PROJECT_DIR/target/example"
EXAMPLES=$($PROJECT_DIR/compile.py --examples)

for example in $EXAMPLES; do
  file_path="$PROJECT_DIR/example/$example"
  # if a compopts file exists, compile for each one
  compopts_file="${file_path%.chpl}.compopts"
  if [[ -f "$compopts_file" ]]; then
    while IFS= read -r compopts || [[ -n "$compopts" ]]; do
      # skip empty lines and comments
      if [[ -z "$compopts" || "$compopts" =~ ^# ]]; then
        continue
      fi
      build_and_run "$file_path" "$compopts"
    done < "$compopts_file"
  else
    build_and_run "$file_path" ""
  fi
done
