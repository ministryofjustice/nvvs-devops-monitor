# Upgrading Kubernetes version
The below documents the upgrade of Kubernetes from version 1.26 to version 1.27. For future upgrades please check the process using AWS documentation.

## Backup Resources
Backup cluster configurations using the comand:
```bash
kubectl get all -A -o yaml >backup-v1.26
```
Check current version:
```bash
aws eks describe-cluster --name nvvs-devops-monitor-eks-development
```
## EKS upgrade
The upgrade itself can be done using the console or AWS cli. The below outlines how to do it using the AWS cli.
### Upgrade Cluster Version
Check current cluster version:
```bash
kubectl version -short
```
Run command to update version (change the version according to the version required):
```bash
aws eks --region eu-west-2 update-cluster-version --name nvvs-devops-monitor-eks-development  --kubernetes-version 1.27
```
Check upgraded version (note this may take some time to see the update):
```bash
kubectl version -short 
```
### Upgrade Node Version
Check current node version:
```bash
kubectl get node -o wide
```
Run command to update version (change the version according to the version required):
```bash
aws eks update-nodegroup-version --cluster-name nvvs-devops-monitor-eks-development --nodegroup-name green --kubernetes-version 1.27
```
Check upgraded version (note this may take some time to see the update):
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.status.nodeInfo.kubeletVersion}{'\n'}"
```
### Upgrade Kube-proxy version
Check version:
```bash
kubectl get daemonset kube-proxy -n kube-system -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
```
To upgrade to the required version you need to check [here](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) for the compatible Kubernetes version.
Once you have noted the corrent kube-proxy version you need to change the image version in the daemonset to the supported version i.e for 1.27 “v1.27.16-eksbuild.14”
```bash
kubectl edit daemonset kube-proxy -n kube-system
```
Once that has been done, check the version by looking at the logs:
```bash
kubectl logs -n kube-system -l k8s-app=kube-proxy
```
### Upgrade CoreDNS version
Check version:
```bash
kubectl get deployment coredns -n kube-system -o jsonpath='{$.spec.template.spec.containers[:1].image}'
```
To upgrade to the required version you need to check [here](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) for the compatible Kubernetes version.
Once you have noted the correct version you need to edit the image version to match the supported version for the cluster:
```bash
kubectl edit deployment coredns -n kube-system
```
### Upgrade VPC CNI version
Check version:
```bash
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3
```
To upgrade to the required version you need to check [here](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html) for the compatible Kubernetes version.
If the version needs changing you need set the new image:
```bash
kubectl set image daemonset aws-node -n kube-system \
  aws-node=<accountnumber>.dkr.ecr.eu-west-2.amazonaws.com/amazon-k8s-cni:v1.18.6-eksbuild.1
```
