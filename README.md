# Kubernetes plugin for drone.io with kubectl v1.23.3

This plugin allows to update Kubernetes resources by a YAML file.

## Build

```bash
docker buildx create --name mycrossbuilder
docker buildx use mycrossbuilder
docker buildx ls
docker buildx inspect --bootstrap

docker buildx build --platform linux/amd64,linux/arm64  \
                    -t juouyang/drone-kubectl:v1.23.3 --push .
```

## Prerequisite

`drone-runner-kube` MUST install and this plugin is for in-cluster operation ONLY.
  * use `serviceaccount/drone/default`, and CANNOT use other credential currently
  * cannot control remote k8s (out-cluster)

### RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: drone-default-sa-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: drone
```

## Usage

.drone.yml
```yaml
kind: pipeline
type: kubernetes
name: default

steps:

  - name: staging
    image: juouyang/drone-kubectl:v1.23.3
    settings:
      target_image: juouyang/k8scicd:${DRONE_COMMIT_SHA:0:7}
    commands:
      - envsubst < deploy.yml | kubectl apply -f -
```

deploy.yml
```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: k8scicd
  name: k8scicd
spec:
  finalizers:
  - kubernete
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: demo
  name: demo
  namespace: k8scicd
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: demo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: demo
  name: demo
  namespace: k8scicd
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: demo
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - image: $PLUGIN_TARGET_IMAGE
        imagePullPolicy: IfNotPresent
        name: k8scicd
        ports:
        - containerPort: 8080
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo
  namespace: k8scicd
spec:
  ingressClassName: nginx
  rules:
  - host: k8scicd.example.com
    http:
      paths:
      - backend:
          service:
            name: demo
            port:
              number: 8080
        path: /
        pathType: Exact
  tls:
  - hosts:
    - k8scicd.example.com
```
