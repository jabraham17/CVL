#!/usr/bin/env bash

PROJECT_DIR=$(cd $(dirname $0); cd ..; pwd)
REG=$PROJECT_DIR/.registry
REG_NAME="local-registry"
MASON_HOME=$(mason env | grep MASON_HOME | cut -d: -f2 | tr -d ' ')

if [[ -d $REG ]]; then
  echo "Using existing local registry at $REG"
else
  rm -rf $MASON_HOME/$REG_NAME
  (cd $PROJECT_DIR && mkdir -p $REG && git init $REG -M main)
fi

dummyVersion=0.0.0
dummyTag=v$dummyVersion

# create the dummy tag, if it already exists, remove it and create it again
if (cd $PROJECT_DIR && git rev-parse $dummyTag >/dev/null 2>&1); then
  echo "Dummy tag $dummyTag already exists, deleting it and creating it again"
  (cd $PROJECT_DIR && git tag -d $dummyTag)
fi
(cd $PROJECT_DIR && git tag $dummyTag)

# copy the toml to the registry as dummyVersion.toml, then rewrite the source
# and version
mkdir -p $REG/Bricks/CVL/
cp $PROJECT_DIR/Mason.toml $REG/Bricks/CVL/$dummyVersion.toml
sed -E -e "s|source\s*=\s*\".*\"|source=\"$PROJECT_DIR\"|" -e "s|version\s*=\s*\".*\"|version=\"$dummyVersion\"|" $REG/Bricks/CVL/$dummyVersion.toml > $REG/Bricks/CVL/$dummyVersion.tmp.toml
mv $REG/Bricks/CVL/$dummyVersion.tmp.toml $REG/Bricks/CVL/$dummyVersion.toml

# commit the new entry
(cd $REG && git add . && git commit -m "Added $dummyTag.toml for local registry")

# clear the old repo
rm -rf $MASON_HOME/src/CVL-$dummyVersion

export MASON_REGISTRY="local-registry|$REG"
