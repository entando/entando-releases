#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../.."

. ./manifest
. "$DIR/_base.sh"

set -e 

TPLD="$D/ge-1-1-6/plain-templates"
SMPD="$D/ge-1-1-6/samples"

_set_placeholders() {
  local TPL="$1"
  local APPVER="7.0"
  local REPLICA="1"
  local IMGTYPE="eap"
  local DB="${OVERRIDE_DB_TYPE:-"embedded"}"
  local ENTANDO_HOSTNAME="YOUR-HOST-NAME"
  local ENTANDO_NAMESPACE="entando"
  local ENTANDO_APPNAME="quickstart"
  
  cat - \
    | sed "s/{{ENTANDO_NAMESPACE}}/$ENTANDO_NAMESPACE/" \
    | sed "s/{{ENTANDO_APP_NAME}}/$ENTANDO_APPNAME/" \
    | sed "s/{{ENTANDO_HOSTNAME}}/$ENTANDO_HOSTNAME/" \
    | sed "s/{{ENTANDO_APP_IMAGE_TYPE}}/$IMGTYPE/" \
    | sed "s/{{ENTANDO_APP_REPLICAS}}/$REPLICA/" \
    | sed "s/{{ENTANDO_DBMS}}/$DB/" \
    | sed "s/{{ENTANDO_APP_VERSION}}/\"$APPVER\"/" \
    | sed "s/{{ENTANDO_VARS}}/null/" \
    ;
}

mkdir -p "$SMPD"

cat "$TPLD/base/entando-app.yaml" | _set_placeholders > "$SMPD/entando-app.yaml"
cat "$TPLD/base/entando-operator-config.yaml" | _set_placeholders > "$SMPD/entando-operator-config.yaml"
