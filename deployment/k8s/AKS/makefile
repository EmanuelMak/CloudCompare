.PHONY: listAkst

AKS_CLUSTER_NAME=my-aks-cluster

listAks:
	- az aks list
getAzSubscriptionId:
	- az account list |  grep -o P '(?<="id": ")[^"]*'

setKubectlAksContext:
	- mv ~/.kube/config ~/.kube/config.bak
	- mv kubeconfig ~/.kube/config

resetKubectlAksContext:
	- mv ~/.kube/config.bak ~/.kube/config