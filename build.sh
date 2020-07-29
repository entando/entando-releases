#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

. ./manifest
. .wd/scripts/_base.sh

$S/init.sh force
$S/gen.sh force

TPL=""

set -e

[ -f "$D/manifest.yaml" ] && rm "$D/manifest.yaml"
touch "$D/manifest.yaml"

.wd/scripts/qs-gen.sh
echo "File \"$D/qs/entando.yaml\" generated"

while IFS= read -r line
do
  eval "echo \"$line\"" >> "$D/manifest.yaml"
done < ".wd/res/manifest.yaml.tpl"

echo "File \"$D/manifest.yaml\" built"

cp "manifest" "$D/manifest"
echo "File \"$D/manifest\" copied"

tar cfz "$D/qs/custom-resources.tar.gz" "$D/crd"
echo "File \"$D/crd\" built"

