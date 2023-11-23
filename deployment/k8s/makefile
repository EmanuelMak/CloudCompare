.PHONY: minikubeConfig minikubeAdonns checkMinikube checkIfKubernetesMetricsServerIsRunning helmAddDependencys helmInstall helmDelete

minikubeConfig:
	- minikube start --driver=docker --kubernetes-version v1.28.3 --cpus=4 --disk-size='5000mb' --memory='3000mb'

minikubeAdonns:
	- minikube addons enable ingress
	- minikube addons enable metrics-server

checkMinikube:
	- minikube status
	- kubectl cluster-info
	- kubectl get nodes
	- kubectl create deployment nginx --image=nginx
	- kubectl expose deployment nginx --type=NodePort --port=80
	- kubectl get deployments
	- minikube service nginx

checkIfKubernetesMetricsServerIsRunning:
	- kubectl get pods -n kube-system | grep metrics-server

helmAddDependencys:
	- cd ./helm && helm upgrade thesis-cloudcompare-release . -f values.yaml -f external-values.yaml

helmInstall:
	- cd ./helm && helm install thesis-cloudcompare-release . -f values.yaml -f external-values.yaml

helmDelete:
	- cd ./helm && helm delete thesis-cloudcompare-release . -f values.yaml -f external-values.yaml

helmDependencyUpdate:
	- helm dependency update ./helm

stepsForLocalKubernetes:
	- make helmDependencyUpdate
	- kubectl apply -f components.yaml
	- make helmInstall
	- kubectl patch deployment test-release-metrics-server -n default --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'


applyNecessaryChanges:
	- kubectl patch deployment test-release-metrics-server -n default --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
	- helm install my-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.service.type=LoadBalancer --set controller.service.externalTrafficPolicy=Local
listEverything:
	-  kubectl get all -n default
	- helm list
	- kubectl get pods


getLoadbalancerurl:
	- kubectl get service thesis-cloudcompare-release-ingress-nginx-controller

getExternalValues:
	- vlt secrets get --plaintext k8s_values > ./helm/external-values.yaml