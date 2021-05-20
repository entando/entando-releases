#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR/../.."

. ./manifest
. "$DIR/_base.sh"

set -e 

# --------------------------------------------------------------------------------
# GENERATION
# --------------------------------------------------------------------------------

# ----------------------------------------
# COLLECTION OF THE ADDITIONAL HELM QUICKSTART FILES
# - entando-operator-config

echo "> Collecting the operator configuration configmap"

cp -a -R \
  "$T/$REPO_QUICKSTART_DIR/sample-configmaps/entando-operator-config.yaml" \
  "$D/entando-operator-config.yaml"

# ----------------------------------------
# COLLECTION OF THE OPERATOR BUNDLE FILES
# - entando-operator-config

echo "> Collecting the operator deployment files"

cp -a -R \
  "$T/$REPO_OPERATOR_BUNDLE_DIR/manifests/k8s-before-116/namespace-scoped-deployment/" \
  "$T/namespace-scoped-deployment-lt-1-1-6/"

echo "> \"$T/namespace-scoped-deployment-lt-1-1-6\" collected"

cp -a -R \
  "$T/$REPO_OPERATOR_BUNDLE_DIR/manifests/k8s-116-and-later/namespace-scoped-deployment" \
  "$T/namespace-scoped-deployment-ge-1-1-6"

echo "> \"$T/namespace-scoped-deployment-ge-1-1-6\" collected"

# ----------------------------------------
# MANIFEST - GENERATION

echo "> Final manifests generation"

(
  cd "$T/$REPO_QUICKSTART_DIR"
  
  helm dependency update ./

  cat "./values.yaml.tpl" \
    | sed 's/#*\([[:space:]]*singleHostName:\).*/\1 PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME/' \
    > "./values.yaml"

  case "$HELM_VERSION_MAJOR" in
    2)
      helm template --name "PLACEHOLDER_ENTANDO_APPNAME" --namespace="PLACEHOLDER_ENTANDO_NAMESPACE" . \
        > "./$DEPL_SPEC_YAML_FILE.tmp"
      ;;
    3)
      helm template "PLACEHOLDER_ENTANDO_APPNAME" --namespace="PLACEHOLDER_ENTANDO_NAMESPACE" . \
        > "./$DEPL_SPEC_YAML_FILE.tmp"
      ;;
  esac
  
) || exit "$?"

# --------------------------------------------------------------------------------
# FINALIZATION
# --------------------------------------------------------------------------------

mkdir -p "$D/lt-1-1-6/namespace-scoped-deployment"
mkdir -p "$D/ge-1-1-6/namespace-scoped-deployment"

# ----------------------------------------
# FINALIZE CLUSTER LEVEL MANIFEST FILES

CLURES="cluster-resources.yaml"

cp "$T/namespace-scoped-deployment-lt-1-1-6/$CLURES" \
   "$D/lt-1-1-6/namespace-scoped-deployment/$CLURES"

cp "$T/namespace-scoped-deployment-ge-1-1-6/$CLURES" \
   "$D/ge-1-1-6/namespace-scoped-deployment/$CLURES"
   

# ----------------------------------------
# PREPARE APPLICATION MANIFEST FILES

cd "$DIR/../.."
NSRES="namespace-resources.yaml"
OC="entando-operator-config.yaml"
QSFILE="$T/$REPO_QUICKSTART_DIR/$DEPL_SPEC_YAML_FILE.tmp"

# ~ K8S < 1.1.6
DST="$T/$DEPL_SPEC_YAML_FILE.lt-1-1-6.tmp"
echo -e "####\n# $NSRES\n#" > "$DST"
cat "$T/namespace-scoped-deployment-lt-1-1-6/$NSRES" >> "$DST"  # namespaced setup
echo -e "\n####\n# $OC\n#" >> "$DST"
cat "$D/$OC" >> "$DST"                                          # parameters
echo -e "\n\n####\n# $DEPL_SPEC_YAML_FILE\n#" >> "$DST"
cat "$QSFILE" >> "$DST"                                         # application
DST=""

# ~ K8S >= 1.1.6
DST="$T/$DEPL_SPEC_YAML_FILE.ge-1-1-6.tmp"
echo -e "####\n# $NSRES\n#" > "$DST"
cat "$T/namespace-scoped-deployment-ge-1-1-6/$NSRES" >> "$DST"  # namespaced setup
echo -e "\n####\n# $OC\n#" >> "$DST"
cat "$D/$OC" >> "$DST"                                          # parameters
echo -e "\n\n####\n# $DEPL_SPEC_YAML_FILE\n#" >> "$DST"
cat "$QSFILE" >> "$DST"                                         # application
DST=""

# ----------------------------------------
# FINALIZE APPLICATION MANIFEST FILES

for f in $T/*.tmp; do 
  TMP="$(basename -- "$f")"
  DST="${TMP%.*}"     # removes the tmp
  VER="${DST##*.}"    # extracts the version-suffix
  DST="${DST%.*}"     # removes the version-suffix
  
  echo "> Generating \"$VER/$DST\""
  
  cat "$f" \
    | sed 's/#*\([[:space:]]*entando\.default\.routing\.suffix:\).*/\1 PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX/' \
    | sed 's/apps\.serv\.run/PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX/' \
    > "$D/$VER/namespace-scoped-deployment/$DST.tpl"
    
  rm "$f"
  
  echo "> done."
done

# ----------------------------------------
# FINALIZE THE ORIGINALS

ORIGS_DIR="$D/ge-1-1-6/namespace-scoped-deployment/orig"
mkdir  "$ORIGS_DIR"
mv "$T/namespace-scoped-deployment-lt-1-1-6/$NSRES" "$ORIGS_DIR/"
mv "$T/namespace-scoped-deployment-lt-1-1-6/$CLURES" "$ORIGS_DIR/"
ORIGS_DIR="$D/lt-1-1-6/namespace-scoped-deployment/orig"
mkdir  "$ORIGS_DIR"
mv "$T/namespace-scoped-deployment-ge-1-1-6/$NSRES" "$ORIGS_DIR/"
mv "$T/namespace-scoped-deployment-ge-1-1-6/$CLURES" "$ORIGS_DIR/"

cd "$DIR/../.."
