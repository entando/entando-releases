---
# Source: preview/charts/operator/templates/k8s-service-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: entando-k8s-service
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/operator-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: entando-operator
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/plugin-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: entando-plugin
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/docker-image-info-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: entando-docker-image-info
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
data:
  app-builder: >-
    {"version":"6.1.353","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-avatar-plugin: >-
    {"version":"6.0.5","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-component-manager: >-
    {"version":"6.2.39","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-de-app-eap: >-
    {"version":"6.3.25","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-de-app-wildfly: >-
    {"version":"6.3.25","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-app-controller: >-
    {"version":"6.2.11","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-app-plugin-link-controller: >-
    {"version":"6.1.3","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-cluster-infrastructure-controller: >-
    {"version":"6.2.8","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-composite-app-controller: >-
    {"version":"6.2.7","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-controller-coordinator: >-
    {"version":"6.2.25","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-database-service-controller: >-
    {"version":"6.2.3","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-dbjob: >-
    {"version":"6.1.4","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-keycloak-controller: >-
    {"version":"6.2.14","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-plugin-controller: >-
    {"version":"6.2.10","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-service: >-
    {"version":"6.2.2","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-keycloak: >-
    {"version":"6.3.1","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-plugin-sidecar: >-
    {"version":"6.0.2","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-process-driven-plugin: >-
    {"version":"6.0.51","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  busybox: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  mysql-57-centos7: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  postgresql-96-centos7: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"entando"}
---
# Source: preview/charts/operator/templates/k8s-service-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: entando-k8s-service
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
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
# Source: preview/charts/operator/templates/operator-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: entando-operator
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
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
      - "pods/exec"
    verbs:
      - "get"
  - apiGroups:
      - ""
    resources:
      - pods
      - services
      - endpoints
      - persistentvolumeclaims
      - configmaps
      - serviceaccounts
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
      - namespaces
      - serviceaccounts
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
---
# Source: preview/charts/operator/templates/plugin-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: entando-plugin
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
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
# Source: preview/charts/operator/templates/pod-viewer-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-viewer
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
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
# Source: preview/charts/operator/templates/default-pod-viewer-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default-pod-viewer-rolebinding
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-viewer
subjects:
  - kind: ServiceAccount
    name: default
    namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/k8s-service-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: entando-k8s-service-rolebinding
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: entando-k8s-service
subjects:
  - kind: ServiceAccount
    name: entando-k8s-service
    namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/operator-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: entando-operator-rolebinding
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: entando-operator
subjects:
  - kind: ServiceAccount
    name: entando-operator
    namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/plugin-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: entando-plugin-rolebinding
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: entando-plugin
subjects:
  - kind: ServiceAccount
    name: entando-plugin
    namespace: PLACEHOLDER_ENTANDO_NAMESPACE
---
# Source: preview/charts/operator/templates/deployment.yaml
apiVersion: "extensions/v1beta1"
kind: Deployment
metadata:
  name: PLACEHOLDER_ENTANDO_APPNAME-operator
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
  labels:
    draft: draft-app
    chart: "operator-6.2.26"
spec:
  replicas: 1
  selector:
    matchLabels:
      draft: draft-app
      app: PLACEHOLDER_ENTANDO_APPNAME-operator
  template:
    metadata:
      labels:
        draft: draft-app
        app: PLACEHOLDER_ENTANDO_APPNAME-operator
    spec:
      serviceAccountName: entando-operator
      volumes:
      containers:
        - name: operator
          image: "docker.io/entando/entando-k8s-controller-coordinator:6.2.26"
          imagePullPolicy: Always
          volumeMounts:
          env:
            - name: ENTANDO_K8S_OPERATOR_SERVICEACCOUNT
              valueFrom:
                fieldRef:
                  fieldPath: spec.serviceAccountName
            - name: ENTANDO_ASSUME_EXTERNAL_HTTPS_PROVIDER
              value: "false"
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
            - name: ENTANDO_K8S_OPERATOR_DISABLE_PVC_GARBAGE_COLLECTION
              value: "false"
            - name: ENTANDO_K8S_OPERATOR_FORCE_DB_PASSWORD_RESET
              value: "true"
            - name: ENTANDO_K8S_OPERATOR_IMPOSE_DEFAULT_LIMITS
              value: "false"
            - name: ENTANDO_K8S_OPERATOR_SECURITY_MODE
              value: "strict"
            - name: ENTANDO_POD_COMPLETION_TIMEOUT_SECONDS
              value: "1000"
            - name: ENTANDO_POD_READINESS_TIMEOUT_SECONDS
              value: "1000"
          livenessProbe:
            exec:
              command:
                - cat
                - /tmp/EntandoControllerCoordinator.ready
            initialDelaySeconds: 60
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            exec:
              command:
                - cat
                - /tmp/EntandoControllerCoordinator.ready
            periodSeconds: 10
            successThreshold: 1
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
# Source: preview/templates/entando-composite-app.yaml
kind: "EntandoCompositeApp"
apiVersion: "entando.org/v1"
metadata:
  name: "PLACEHOLDER_ENTANDO_APPNAME-composite-app"
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
entandoStatus:
  serverStatuses: {}
  entandoDeploymentPhase: "requested"
spec:
  components:
    - kind: "EntandoKeycloakServer"
      metadata:
        name: "PLACEHOLDER_ENTANDO_APPNAME-kc"
      spec:
        dbms: none
        isDefault: true
        replicas: 1
        ingressHostName: PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME
    - kind: "EntandoClusterInfrastructure"
      metadata:
        name: "PLACEHOLDER_ENTANDO_APPNAME-eci"
      spec:
        dbms: none
        replicas: 1
        isDefault: true
        ingressHostName: PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME
    - kind: "EntandoApp"
      metadata:
        annotations: {}
        labels: {}
        name: "PLACEHOLDER_ENTANDO_APPNAME"
      spec:
        dbms: none
        replicas: 1
        standardServerImage: wildfly
        ingressPath: /entando-de-app
        ingressHostName: PLACEHOLDER_ENTANDO_SINGLE_HOSTNAME
