####
# namespace-resources.yaml
#
---
# Source: entando-k8s-operator-bundle/charts/operator/templates/entando-empty-tls-secret.yaml
apiVersion: v1
stringData:
  tls.crt: ''
  tls.key: ''
kind: Secret
metadata:
  name: entando-empty-tls-secret
type: kubernetes.io/tls

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/docker-image-info-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: entando-docker-image-info
data:
  app-builder: >-
    {"version":"6.3.93","executable-type":"n/a","registry":"docker.io","organization":"entando"}
  busybox: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-avatar-plugin: >-
    {"version":"6.0.5","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-component-manager: >-
    {"version":"6.3.26","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-de-app-eap: >-
    {"version":"6.3.68","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-de-app-wildfly: >-
    {"version":"6.3.68","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-app-controller: >-
    {"version":"6.3.12","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-app-plugin-link-controller: >-
    {"version":"6.3.5","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-cluster-infrastructure-controller: >-
    {"version":"6.3.7","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-composite-app-controller: >-
    {"version":"6.3.11","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-database-service-controller: >-
    {"version":"6.3.11","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-dbjob: >-
    {"version":"6.3.8","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-keycloak-controller: >-
    {"version":"6.3.8","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-plugin-controller: >-
    {"version":"6.3.7","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-service: >-
    {"version":"6.3.4","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-keycloak: >-
    {"version":"6.3.9","executable-type":"","registry":"docker.io","organization":"entando"}
  entando-plugin-sidecar: >-
    {"version":"6.0.2","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-process-driven-plugin: >-
    {"version":"6.0.50","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-redhat-sso: >-
    {"version":"6.3.9","executable-type":"","registry":"docker.io","organization":"entando"}
  mysql-80-centos7: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"centos"}
  postgresql-12-centos7: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"centos"}
  rhel8-mysql-80: >-
    {"version":"latest","executable-type":"jvm","registry":"registry.redhat.io","organization":"rhel8"}
  rhel8-postgresql-12: >-
    {"version":"latest","executable-type":"jvm","registry":"registry.redhat.io","organization":"rhel8"}

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/k8s-service-serviceaccount.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: entando-k8s-service
imagePullSecrets:
  - name: redhat-registry
  - name: entando-pull-secret

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/operator-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: entando-operator
imagePullSecrets:
  - name: redhat-registry
  - name: entando-pull-secret

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/plugin-serviceaccount.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: entando-plugin
imagePullSecrets:
  - name: redhat-registry
  - name: entando-pull-secret

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/k8s-service-role.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: entando-k8s-service
rules:
  - apiGroups:
      - entando.org
    resources:
      - entandokeycloakservers
      - entandokeycloakservers/finalizers
      - entandoclusterinfrastructures
      - entandoclusterinfrastructures/finalizers
      - entandoapps
      - entandoapps/finalizers
      - entandoplugins
      - entandoplugins/finalizers
      - entandoapppluginlinks
      - entandoapppluginlinks/finalizers
      - entandodatabaseservices
      - entandodatabaseservices/finalizers
      - entandocompositeapps
      - entandocompositeapps/finalizers
      - entandodebundles
      - entandodebundles/finalizers
    verbs:
      - "*"
  - apiGroups:
      - extensions
    resources:
      - ingresses
    verbs:
      - "*"
  - apiGroups:
      - route.openshift.io
    resources:
      - "routes"
      - "routes/custom-host"
    verbs:
      - "*"
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - create
      - get
      - delete
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - "*"
  - apiGroups:
      - ""
    resources:
      - namespaces
    verbs:
      - get
---
# Source: entando-k8s-operator-bundle/charts/operator/templates/operator-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: entando-operator
rules:
  - apiGroups:
      - entando.org
    resources:
      - "*"
    verbs:
      - "*"
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - create
      - get
      - delete
      - update
  - apiGroups:
      - ""
    resources:
      - pods
      - services
      - endpoints
      - persistentvolumeclaims
      - configmaps
      - serviceaccounts
      - events
    verbs:
      - "*"
  - apiGroups:
      - apps
      - extensions
    resources:
      - deployments
    verbs:
      - "*"
  - apiGroups:
      - apiextensions.k8s.io
    resources:
      - customresourcedefinitions
    verbs:
      - get
  - apiGroups:
      - extensions
    resources:
      - ingresses
    verbs:
      - "*"
  - apiGroups:
      - ""
    resources:
      - namespaces
      - pods/exec
    verbs:
      - get
  - apiGroups:
      - rbac.authorization.k8s.io
    resources:
      - roles
    verbs:
      - get
  - apiGroups:
      - rbac.authorization.k8s.io
    resources:
      - rolebindings
    verbs:
      - get
      - create
  - apiGroups:
      - route.openshift.io
    resources:
      - "routes"
      - "routes/custom-host"
    verbs:
      - "*"

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/plugin-role.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: entando-plugin
rules:
  - apiGroups:
      - entando.org
    resources:
      - entandoplugins
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - secrets
    verbs:
      - create
      - get
      - delete
      - update

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/pod-viewer-role.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-viewer
rules:
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - "list"
      - "get"
      - "watch"
---
# Source: entando-k8s-operator-bundle/charts/operator/templates/default-pod-viewer-rolebinding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-pod-viewer-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-viewer
subjects:
  - kind: ServiceAccount
    name: default
---
# Source: entando-k8s-operator-bundle/charts/operator/templates/k8s-service-rolebinding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: entando-k8s-service-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: entando-k8s-service
subjects:
  - kind: ServiceAccount
    name: entando-k8s-service

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/operator-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: entando-operator-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: entando-operator
subjects:
  - kind: ServiceAccount
    name: entando-operator

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/plugin-rolebinding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: entando-plugin-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: entando-plugin
subjects:
  - kind: ServiceAccount
    name: entando-plugin

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/deployment.yaml
apiVersion: "apps/v1"
kind: Deployment
metadata:
  name: entando-operator
  labels:
    draft: draft-app
    chart: "operator-6.3.9"
spec:
  replicas: 1
  selector:
    matchLabels:
      draft: draft-app
      app: entando-operator
  template:
    metadata:
      labels:
        draft: draft-app
        app: entando-operator
    spec:
      serviceAccountName: entando-operator
      volumes:
      containers:
        - name: operator
          image: "docker.io/entando/entando-k8s-controller-coordinator:6.3.9"
          imagePullPolicy: Always
          volumeMounts:
          env:
            - name: ENTANDO_K8S_OPERATOR_IMAGE_PULL_SECRETS
              value: "redhat-registry,entando-pull-secret"
            - name: ENTANDO_K8S_OPERATOR_SERVICEACCOUNT
              valueFrom:
                fieldRef:
                  fieldPath: spec.serviceAccountName
            - name: ENTANDO_DEFAULT_ROUTING_SUFFIX
              value: "PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX"
            - name: ENTANDO_DISABLE_KEYCLOAK_SSL_REQUIREMENT
              value: "true"
            - name: ENTANDO_DOCKER_IMAGE_ORG_FALLBACK
              value: "entando"
            - name: ENTANDO_DOCKER_IMAGE_VERSION_FALLBACK
              value: "6.0.0"
            - name: ENTANDO_DOCKER_REGISTRY_FALLBACK
              value: "docker.io"
            - name: ENTANDO_K8S_OPERATOR_SECURITY_MODE
              value: "strict"
            - name: ENTANDO_POD_COMPLETION_TIMEOUT_SECONDS
              value: "600"
            - name: ENTANDO_POD_READINESS_TIMEOUT_SECONDS
              value: "600"
          startupProbe:
            exec:
              command:
                - cat
                - /tmp/EntandoControllerCoordinator.ready
            periodSeconds: 3
            failureThreshold: 20
            successThreshold: 1
            timeoutSeconds: 1
          livenessProbe:
            exec:
              command:
                - cat
                - /tmp/EntandoControllerCoordinator.ready
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            exec:
              command:
                - cat
                - /tmp/EntandoControllerCoordinator.ready
            periodSeconds: 5
            failureThreshold: 1
            timeoutSeconds: 1
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 400m
              memory: 512Mi
          terminationGracePeriodSeconds: 

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/operator-clusterrole.yaml

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/operator-clusterrolebinding.yaml

---
# Source: entando-k8s-operator-bundle/charts/operator/templates/operator-pod-viewer-clusterrolebinding.yaml

---
# Source: entando-k8s-operator-bundle/templates/docker-image-info-configmap.yaml

---
# Source: entando-k8s-operator-bundle/templates/entando-empty-tls-secret.yaml

---
# Source: entando-k8s-operator-bundle/templates/entando-k8s-operator.v6.3.x.clusterserviceversion.yaml


####
# entando-operator-config.yaml
#
apiVersion: v1
kind: ConfigMap
metadata:
  name: entando-operator-config
data:
# For slow environments with low bandwidth, you can given the various pods more time to get to ready state and/or completion state by
# increasing the values for the following two properties
  entando.pod.completion.timeout.seconds: "600"
  entando.pod.readiness.timeout.seconds: "600"

# if you want to specify an additional image pull secret for the Entando operator to use, add the dockercfg json  in the
# sample-secrets/sample-pull-secret.yaml file, create the secret in  [your-sandbox-namespace]
# and uncomment the property 'entando.k8s.operator.image.pull.secrets'
#
#  entando.k8s.operator.image.pull.secrets: sample-pull-secret

# if you want to load the Entando containers from a private registry, specify the hostname using the
# property 'entando.docker.registry.override'. This is often used in conjunction with the property 'entando.k8s.operator.image.pull.secrets'
#
#  entando.docker.registry.override: "docker.io"

# if you want to retain all storage that was allocated even when the Entando custom resource it was provided for is
# deleted, then set the 'entando.k8s.operator.disable.pvc.garbage.collection' property to "true"
#  entando.k8s.operator.disable.pvc.garbage.collection: "true"

# if you want to expose all your services over TLS, specify the certificate and key in the sample-secrets/sample-tls-secret.yaml
# file, create the secret in  [your-sandbox-namespace]  and uncomment the property 'entando.tls.secret.name'
#
#  entando.tls.secret.name: sample-tls-secret

# if you want to access services with self signed certificate, or if your own TLS certificate was self signed, specify the certificate(s)
# in the  sample-secrets/sample-ca-cert-secret.yaml file, create the secret in  [your-sandbox-namespace]
# and uncomment the property 'entando.ca.secret.name'
#  entando.ca.secret.name: sample-ca-cert-secret


# if you want to specify a global routing suffix, set the value of the 'entando.default.routing.suffix' property to a
# domain suffix that will resolve to your cluster host. For Entando custom resource that do not specify an ingress
# hostname, the hostnames for deployments will be calculated by prefixing the name and namespace of the resource to this
# routing suffix.
#
  entando.default.routing.suffix: PLACEHOLDER_ENTANDO_DOMAIN_SUFFIX

# if you want to inspect the Entando deployer pods even after deployment has completed successfully, you can turn of
# the deployer pod garbage collection by setting the property 'entando.k8s.operator.gc.controller.pods' to "false"
#
  entando.k8s.operator.gc.controller.pods: "true"

# if you want to regain access to you shared database without having to recreated schemas, but you also want to
# delete the Entando custom resources at will, you will need to  instruct the Entando operator to force a password
# reset by setting the 'entando.k8s.operator.force.db.password.reset' property to "true"


####
# entando-deployment-specs.yaml
#
---
# Source: entando-helm-quickstart/templates/entando-app.yaml
apiVersion: "entando.org/v1"
kind: "EntandoApp"
metadata:
  name: "PLACEHOLDER_ENTANDO_APPNAME"
  annotations:
    entando.org/processing-instruction: defer
spec:
  dbms: embedded
  ingressHostName: PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME
  replicas: 1
  standardServerImage: wildfly
  ingressPath: /entando-de-app
---
# Source: entando-helm-quickstart/templates/entando-cluster-infrastructure.yaml
apiVersion: "entando.org/v1"
kind: "EntandoClusterInfrastructure"
metadata:
  name: "PLACEHOLDER_ENTANDO_APPNAME-eci"
  annotations:
    entando.org/processing-instruction: defer
spec:
  ingressHostName: PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME
  replicas: 1
  isDefault: true
---
# Source: entando-helm-quickstart/templates/entando-composite-app.yaml
kind: "EntandoCompositeApp"
apiVersion: "entando.org/v1"
metadata:
  name: "PLACEHOLDER_ENTANDO_APPNAME-composite-app"
spec:
  components:
    - kind: "EntandoCustomResourceReference"
      metadata:
        name: "keycloak-server"
      spec:
        targetKind: "EntandoKeycloakServer"
        targetName: "PLACEHOLDER_ENTANDO_APPNAME-kc"
    - kind: "EntandoCustomResourceReference"
      metadata:
        name: "PLACEHOLDER_ENTANDO_APPNAME-eci"
      spec:
        targetKind: "EntandoClusterInfrastructure"
        targetName: "PLACEHOLDER_ENTANDO_APPNAME-eci"
    - kind: "EntandoCustomResourceReference"
      metadata:
        name: "app"
      spec:
        targetKind: "EntandoApp"
        targetName: "PLACEHOLDER_ENTANDO_APPNAME"
---
# Source: entando-helm-quickstart/templates/entando-keycloak-server.yaml
kind: "EntandoKeycloakServer"
apiVersion: "entando.org/v1"
metadata:
  name: "PLACEHOLDER_ENTANDO_APPNAME-kc"
  annotations:
    entando.org/processing-instruction: defer
spec:
  dbms: embedded
  ingressHostName: PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME
  isDefault: true
  replicas: 1
