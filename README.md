# Kubernetes plugin for drone.io with kubectl v1.23.3

This plugin allows to deploy an image to kubernetes cluster.

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

drone-runner-kube MUST install and this plugin is for in-cluster operation.
  * use serviceaccount/drone/default, and CANNOT use other credential currently
  * cannot control remote k8s without drone-runner-kube install

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

## Usage (.drone.yml)

```yaml
kind: pipeline
type: kubernetes
name: default

steps:

  - name: staging
    image: juouyang/drone-kubectl:v1.23.3
    commands:
      - kubectl create deployment demo --image=httpd --port=80 -n demo
      - kubectl expose deployment demo -n demo
      - kubectl create ingress demo --class=nginx --rule="demo.example.com/*=demo:80" -n demo
```

