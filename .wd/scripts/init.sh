#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../.."

. ./manifest
. "$DIR/_base.sh"

set -e

rm -rf "$T"

# PREREQ
mkdir -p "$T"

echo "> Found helm version $HELM_VERSION_MAJOR ($CURRENT_HELM_VERSION) $ => OK"

# -- REPOS

(
  cd "$T" || {
    echo "Error entering dir \"$T\""
    exit 99
  }

  # REPOS -- OPERATOR BUNDLE
  echo -e "> Cloning the OPERATOR BUNDLE REPO"
  [ "$1" == "force" ] && [ -d "$REPO_OPERATOR_BUNDLE_DIR" ] && rm -rf "./$REPO_OPERATOR_BUNDLE_DIR"
  clone "$REPO_OPERATOR_BUNDLE_ADDR" "$OPERATOR_BUNDLE_VERSION" "$REPO_OPERATOR_BUNDLE_DIR" "operator bundle"

  # REPOS -- QUICKSTART
  echo -e "> Cloning the QUICKSTART REPO"
  [ "$1" == "force" ] && [ -d "$REPO_QUICKSTART_DIR" ] && rm -rf "./$REPO_QUICKSTART_DIR"
  clone "$REPO_QUICKSTART_ADDR" "$QUICKSTART_VERSION" "$REPO_QUICKSTART_DIR" "quickstart"

  cd "$REPO_QUICKSTART_DIR"
  [ ! -f values.yaml.tpl ] && cp values.yaml values.yaml.tpl
)
# --
