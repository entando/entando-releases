#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../.."

. ./manifest
. "$DIR/_base.sh"

set -e 

[ "$1" == "force" ] && {
  [ -d "$D/crd" ] && rm -rf "$D/crd"
  [ -f "$D/$DEPL_SPEC_YAML_FILE.tpl" ] && rm "$D/$DEPL_SPEC_YAML_FILE.tpl"
  shift
}

mkdir -p "$D/qs"

cat "$D/entando-deployment-specs.yaml.tpl" \
  | sed "s/PLACEHOLDER_ENTANDO_NAMESPACE/$QS_NAMESPACE/" \
  | sed "s/PLACEHOLDER_ENTANDO_APPNAME/$QS_APPNAME/" \
  | sed "s/your\\.domain\\.suffix\\.com/$QS_ADDR/" \
  > "$D/qs/entando.yaml"
