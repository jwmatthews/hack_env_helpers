clustername=$1
region=$2

eksctl utils write-kubeconfig --cluster $clustername --region $region  --kubeconfig=$clustername.$region.kubeconfig

