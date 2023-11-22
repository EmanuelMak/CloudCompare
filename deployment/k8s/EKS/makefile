.PHONY: setKubectlAwsContext

EKS_CLUSTER_NAME=my-eks-cluster

setKubectlAwsContext:
	- aws eks update-kubeconfig --name $(EKS_CLUSTER_NAME)

addClusterAutoScaler:
	- helm repo add autoscaler https://kubernetes.github.io/autoscaler
	- helm repo update
	- helm install cluster-autoscaler autoscaler/cluster-autoscaler-chart \
    --namespace kube-system \
    --set autoDiscovery.clusterName=my-eks-cluster \
    --set awsRegion=$$AWS_DEFAULT_REGION \
    --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::[ACCOUNT_ID]:role/EKS-ClusterAutoscaler"


setSSHKeyForEC2:
	- ssh-keygen -t rsa -b 2048 -f my-eks-key
	- base64 my-eks-key.pub
	- aws ec2 import-key-pair --key-name "my-eks-key" --public-key-material ./my-eks-key.pub

deployToAWS:
	terraform init
	terrarom apply -auto-approve
	make setKubectlAwsContext
updateExternalValues:
	chmod +x ./generateExternalValues.sh 
	./generateExternalValues.sh 
	file_content=$$(cat ./external-values.yaml); \
	vlt secrets update k8s_values "$$file_content" || vlt secrets create k8s_values "$$file_content"


	

