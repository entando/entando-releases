#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

P() {
  echo ""
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "$1"
  echo ""
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P "ENVIRONMENT AND PARAMETERS"

. ./manifest
. .wd/scripts/_base.sh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P "OUTPUT CLEANUP"

rm -rf ./dist
mkdir ./dist

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P "INITIALIZATION"

$S/init.sh force

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P "DIST GENERATION"

$S/gen.sh force
$S/smp-gen.sh force

TPL=""

set -e

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
P "ADDING THE PARAMETERS FILES"

[ -f "$D/manifest.yaml" ] && rm "$D/manifest.yaml"
touch "$D/manifest.yaml"

while IFS= read -r line
do
  eval "echo \"$line\"" >> "$D/manifest.yaml"
done < "./.wd/res/manifest.yaml.tpl"

echo "File \"$D/manifest.yaml\" built"

cp "manifest" "$D/manifest"
echo "File \"$D/manifest\" copied"
