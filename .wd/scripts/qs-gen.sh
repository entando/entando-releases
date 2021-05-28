#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../.."

. ./manifest
. "$DIR/_base.sh"

set -e 

mkdir -p "$D/qs"

cat "$D/$DEPL_SPEC_YAML_FILE.tpl" \
  | sed "s/PLACEHOLDER_ENTANDO_NAMESPACE/$QS_NAMESPACE/" \
  | sed "s/PLACEHOLDER_ENTANDO_APPNAME/$QS_APPNAME/" \
  | sed "s/PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX/$QS_ADDR/" \
  | sed "/PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME/d" \
  > "$D/qs/entando.yaml"

  cat "$D/$DEPL_SPEC_YAML_FILE.OKD3.tpl" \
  | sed "s/PLACEHOLDER_ENTANDO_NAMESPACE/$QS_NAMESPACE/" \
  | sed "s/PLACEHOLDER_ENTANDO_APPNAME/$QS_APPNAME/" \
  | sed "s/PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX/$QS_ADDR/" \
  | sed "/PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME/d" \
  > "$D/qs/entando-okd3.yaml"

cat "$D/$DEPL_SPEC_YAML_FILE.OKD4.tpl" \
  | sed "s/PLACEHOLDER_ENTANDO_NAMESPACE/$QS_NAMESPACE/" \
  | sed "s/PLACEHOLDER_ENTANDO_APPNAME/$QS_APPNAME/" \
  | sed "s/PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX/$QS_ADDR/" \
  | sed "/PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME/d" \
  > "$D/qs/entando-okd4.yaml"
