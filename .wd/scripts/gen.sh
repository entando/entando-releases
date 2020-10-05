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

reload_cfg

# CHECKS
CURRENT_HELM_VERSION=$(helm version --client | sed 's/.*SemVer:"\([^"]*\)".*/\1/')
[[ ! "$CURRENT_HELM_VERSION" =~ $REQUIRED_HELM_VERSION_REGEX ]] && echo "> FATAL: Found helm version $CURRENT_HELM_VERSION, required: $REQUIRED_HELM_VERSION_REGEX" 1>&2 && exit

# CUSTOM MODEL
cp -i -r "$T/$REPO_CUSTOM_MODEL_DIR/src/main/resources/crd/" "$D"

echo "> \"$D/crd\" built"

# SPECIFICATION FOR OPENSHIFT
cd "$T/$REPO_QUICKSTART_DIR"
helm dependency update ./

cat values.yaml.tpl \
  | sed "s/supportOpenshift:.*$/supportOpenshift: true/" \
  | sed "s/name:.*/name: ##ENTANDO_APPNAME##/" \
  > values.yaml

helm template "PLACEHOLDER_ENTANDO_APPNAME" --namespace="PLACEHOLDER_ENTANDO_NAMESPACE" . > "./$DEPL_SPEC_YAML_FILE"

cd "$DIR/../.."
mv "$T/$REPO_QUICKSTART_DIR/$DEPL_SPEC_YAML_FILE" "$D/$DEPL_SPEC_YAML_FILE.OKD.tpl"

echo "> \"$D/$DEPL_SPEC_YAML_FILE.OKD.tpl\" built"

# SPECIFICATION NON-OPENSHIFT
cd "$T/$REPO_QUICKSTART_DIR"

cat values.yaml.tpl \
  | sed "s/supportOpenshift:.*$/supportOpenshift: false/" \
  | sed "s/name:.*/name: PLACEHOLDER_ENTANDO_APPNAME/" \
  > values.yaml
  
helm template "PLACEHOLDER_ENTANDO_APPNAME" --namespace="PLACEHOLDER_ENTANDO_NAMESPACE" ./ > "./$DEPL_SPEC_YAML_FILE"

cd "$DIR/../.."
mv "$T/$REPO_QUICKSTART_DIR/$DEPL_SPEC_YAML_FILE" "$D/$DEPL_SPEC_YAML_FILE.tpl"

echo "> \"$D/$DEPL_SPEC_YAML_FILE.tpl\" built"
