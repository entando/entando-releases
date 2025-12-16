#!/usr/bin/env bash
set -eo pipefail

# Check if kubernetes is installed
if ! [ -x "$(command -v kubectl)" ]; then
  echo >&2 "Error: kubectl is not installed."
  exit 1
fi

# We need to get the correct namespace from the user
read -p "Enter the target namespace: " namespace

# Check if the namespace exists, otherwise exit
if ! kubectl get ns "${namespace}"; then
  echo "The namespace does not exits. Exiting..."
  exit 1
else
  printf "the target namespace is: %s. \nModifying the current context to %s\n\n" "${namespace}" "${namespace}"
  # Set context to the choosed namespace
  kubectl config set-context --current --namespace="${namespace}"
fi

# scale down all the deployments in the current namespace
kubectl scale deploy --all --replicas=0

echo "Wait 30 seconds to have all the deployments scaled to 0..."
sleep 30

echo "Other 30 seconds and we are done..."
sleep 30

# Check if the cluste is kubernetes or Openshift
clusterType=""
if ! kubectl get ns openshift 2>/dev/null; then
  clusterType="K8S"
else
  clusterType="OCP"
fi

# We need to get the appName value, we'll need it later to update the deployments
appName=$(kubectl get enap --no-headers | awk '{print $1}' | tr -d '\r')

# We need to get also the DB engine, to match the correct deployment name inside the kustomization file
dbEngine=$(kubectl get enap --no-headers | awk '{print $6}' | tr -d '\r\n')
dbDeploymentName=""
if [ $dbEngine == "postgresql" ]; then
  dbDeploymentName="default-postgresql-dbms-in-namespace-deployment.yaml"
fi
if [ $dbEngine == "mysql" ]; then
  dbDeploymentName="default-mysql-dbms-in-namespace-deployment.yaml"
fi

# Create a new directory to store current Entando's deployment manifests
# We need it to be able to patch them with Kustomize
DEST_ROOT_DIR="$PWD/entando-upgrade-${namespace}"
mkdir -p $DEST_ROOT_DIR/{base,overlay}

# we move inside the new base directory to store all the deployment manifests
pushd $DEST_ROOT_DIR/base

# Make a backup of the deployments on your namespace
for n in $(kubectl get deploy --no-headers | awk '{print $1}'); do
  kubectl get deploy "$n" -o yaml >"$n".yaml
done

# We need to create our kustomization.yaml file
cat >kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - $appName-deployment.yaml
  - $appName-cm-deployment.yaml
  - $appName-ab-deployment.yaml
  - default-sso-in-namespace-deployment.yaml
  - $dbDeploymentName
  - entando-k8s-service.yaml
  - entando-operator.yaml
  - pn-3c07adf0-fac54a9f-entando-app-builder-menu-bff-deployment.yaml
EOF

# Exit from the entando-deployments directory
# Enter in the overlay directory
popd

pushd $DEST_ROOT_DIR/overlay

# Create a template for kustomize where we are going to inject the current namespace
cat >base.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base

namespace: $namespace

images:

EOF

# We need to create the kustomization.yaml file inside the overlay directory based on the environment we are working on
if [ $clusterType == "K8S" ]; then
  # We are going to download the K8S template from entando-releases repository
  curl -O https://raw.githubusercontent.com/entando/entando-releases/release/7.2/dist/ge-1-1-6/plain-templates/misc/kustomization-K8S.yaml
else
  curl -O https://raw.githubusercontent.com/entando/entando-releases/release/7.2/dist/ge-1-1-6/plain-templates/misc/kustomization-OCP.yaml
fi

# Generate the final kustomization file
cat base.yaml kustomization-$clusterType.yaml >kustomization.yaml

# Clean dir
rm -f base.yaml kustomization-$clusterType.yaml

# Execute kustomize to patch all the deployments on the cluster

kubectl kustomize | kubectl apply -f -

# Scale all the deployments to 1 replica
kubectl scale deployment --all --replicas=1

echo ""
echo "All the Entando deployments have been patched successfully."
echo ""
echo "Please wait another minute... We are making a backup of the new deploymes to the '$PWD/new-deployments' directory"

mkdir -p new-deployments
pushd new-deployments

# Wait for 1 minute before start the backup process
echo ""
echo "Are you able to count until 10?"
sleep 10

echo ""
echo "Are you able to count until 20?"
sleep 10

echo ""
echo "Are you able to count until 30?"
sleep 10

echo ""
echo "Are you able to count until 40?"
sleep 10

echo ""
echo "Are you able to count until 50?"
sleep 10

echo ""
echo "Are you able to count until 60?"
sleep 10

# Make a backup of the new patched deployments on your namespace
for n in $(kubectl get deploy --no-headers | awk '{print $1}'); do
  kubectl get deploy "$n" -o yaml >"$n".yaml
done

# Exit from the new-deployments directory
popd

echo ""
echo "All the new deployments have been saved."

# Exit from the overlay directory
popd
echo ""
echo "If you want to restore the previous deployments you can find them here: $DEST_ROOT_DIR/base"
