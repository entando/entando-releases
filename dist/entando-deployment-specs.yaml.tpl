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
# Source: preview/charts/operator/templates/ca-cert-secret.yaml
apiVersion: v1
data:
  ca.crt: >-
    
kind: Secret
metadata:
  name: entando-ca-cert-secret
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
type: Opaque
---
# Source: preview/charts/operator/templates/tls-secret.yaml
apiVersion: v1
data:
  tls.crt: >-
    
  tls.key: >-
    
kind: Secret
metadata:
  name: entando-tls-secret
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
type: kubernetes.io/tls
---
# Source: preview/charts/operator/templates/docker-image-info-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: entando-docker-image-info
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
data:
  app-builder: >-
    {"version":"6.1.164","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  busybox: >-
    {"version":"latest","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-avatar-plugin: >-
    {"version":"6.0.5","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-component-manager: >-
    {"version":"6.0.57","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-de-app-eap: >-
    {"version":"6.1.89","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-de-app-wildfly: >-
    {"version":"6.1.89","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-app-controller: >-
    {"version":"6.1.9","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-app-plugin-link-controller: >-
    {"version":"6.1.1","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-cluster-infrastructure-controller: >-
    {"version":"6.1.4","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-composite-app-controller: >-
    {"version":"6.1.4","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-controller-coordinator: >-
    {"version":"6.1.8","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-dbjob: >-
    {"version":"6.1.4","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-keycloak-controller: >-
    {"version":"6.1.15","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-plugin-controller: >-
    {"version":"6.1.4","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-k8s-service: >-
    {"version":"6.0.20","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-keycloak: >-
    {"version":"6.0.15","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-plugin-sidecar: >-
    {"version":"6.0.2","executable-type":"jvm","registry":"docker.io","organization":"entando"}
  entando-process-driven-plugin: >-
    {"version":"6.0.50","executable-type":"jvm","registry":"docker.io","organization":"entando"}
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
      - rolebindings
    verbs:
      - get
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
apiVersion: "apps/v1"
kind: Deployment
metadata:
  name: PLACEHOLDER_ENTANDO_APPNAME-operator
  namespace: PLACEHOLDER_ENTANDO_NAMESPACE
  labels:
    draft: draft-app
    chart: "operator-6.1.11"
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
          image: "docker.io/entando/entando-k8s-controller-coordinator:6.1.11"
          imagePullPolicy: Always
          volumeMounts:
          env:
            - name: ENTANDO_K8S_OPERATOR_SERVICEACCOUNT
              valueFrom:
                fieldRef:
                  fieldPath: spec.serviceAccountName
            - name: ENTANDO_DEFAULT_ROUTING_SUFFIX
              value: "your.domain.suffix.com"
            - name: ENTANDO_DISABLE_KEYCLOAK_SSL_REQUIREMENT
              value: "true"
            - name: ENTANDO_DOCKER_IMAGE_ORG_FALLBACK
              value: "entando"
            - name: ENTANDO_DOCKER_IMAGE_VERSION_FALLBACK
              value: "6.0.0"
            - name: ENTANDO_DOCKER_REGISTRY_FALLBACK
              value: "docker.io"
            - name: ENTANDO_K8S_OPERATOR_FORCE_DB_PASSWORD_RESET
              value: "true"
            - name: ENTANDO_K8S_OPERATOR_IMPOSE_DEFAULT_LIMITS
              value: "false"
            - name: ENTANDO_K8S_OPERATOR_SECURITY_MODE
              value: "lenient"
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
    - kind: "EntandoClusterInfrastructure"
      metadata:
        name: "PLACEHOLDER_ENTANDO_APPNAME-eci"
      spec:
        dbms: none
        replicas: 1
        isDefault: true
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
