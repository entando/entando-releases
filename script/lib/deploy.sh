#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/.."

. lib/_base.sh

ADDR="$1"
[ -z $ADDR ] && ADDR="$(hostname -I | cut -d' ' -f 1)" && COMM=" (autodetected)"

set -e

sed "s/PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX/$ADDR.nip.io/" "d/$DEPL_SPEC_YAML_FILE.tpl" > "d/$DEPL_SPEC_YAML_FILE"

echo "> Using address: $ADDR$COMM"
echo "> Deploying.."

$KK create -f "d/$DEPL_SPEC_YAML_FILE"
