# Entando Kubernetes Custom Resource Definitions.

This folder contains all the Custom Resource Definitions required by the Entando Kubernetes infrastructure in YAML format. 
To register these in your Kubernetes cluster, the person to register them needs cluster level acces with full read/write access
to Kubernetes Custom Resource Definition resources. Once this cluster level read/write access is available, follow these steps 
to register them:
1. Checkout this project:    
    `git clone https://github.com/entando-k8s/entando-k8s-custom-model.git`
2. Navigate to this folder:    
    `cd entando-k8s-custom-model/src/main/resources/crd`
3. Create all of the custom resource defintions:    
    `kubectl create -f .`

NB! Please note that any cluster wide operation on a shared Kubernetes cluster comes with an element of risk. Whoever performs 
these actions needs to have a  good understanding of Custom Resource Definitions on Kubernetes and the possible implications
updating these could have on existing installations of the Entando Operator.
