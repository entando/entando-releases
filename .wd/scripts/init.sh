#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../.."

. ./manifest
. "$DIR/_base.sh"

set -e

rm -rf "$T"

# PREREQ
mkdir -p $T

CURRENT_HELM_VERSION=$(helm version --client | sed 's/.*SemVer:"\([^"]*\)".*/\1/')
[[ ! "$CURRENT_HELM_VERSION" =~ $REQUIRED_HELM_VERSION_REGEX ]] && echo "> FATAL: Found helm version $CURRENT_HELM_VERSION, required: $REQUIRED_HELM_VERSION_REGEX" 1>&2 && exit

echo "> Found helm version $CURRENT_HELM_VERSION => OK"


# -- REPOS
cd $T

# REPOS -- CUSTOM MODEL
git clone "$REPO_CUSTOM_MODEL_ADDR" "$REPO_CUSTOM_MODEL_DIR"
cd "$REPO_CUSTOM_MODEL_DIR"
git checkout -b "$REPO_CUSTOM_MODEL_TAG" "$REPO_CUSTOM_MODEL_TAG" || {
  echo -e '/!\\\n/!\\ Unable to checkout the provided custom model version /!\\\n/!\\' 2>&1
  exit 0
}
cd ..

# REPOS -- QUICKSTART

git clone "$REPO_QUICKSTART_ADDR" "$REPO_QUICKSTART_DIR"
cd "$REPO_QUICKSTART_DIR"
git checkout -b  "$REPO_QUICKSTART_TAG" "$REPO_QUICKSTART_TAG" || {
  echo -e '/!\\\n/!\\ Unable to checkout the provided quickstart version /!\\\n/!\\' 2>&1
  exit 0
}

[ ! -f values.yaml.tpl ] && cp values.yaml values.yaml.tpl
cd ..

# --
cd ..
