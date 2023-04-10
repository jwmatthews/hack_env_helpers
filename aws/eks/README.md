# Create an EKS Cluster
This directory will help you deploy an EKS Cluster with the [EBS CSI AddOn](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) and [Amazon Load Balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) configured.  It relies heavily on the [aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) CLI tools
 * [EBS CSI AddOn](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) allows dynamic PV provisioning
 * [Amazon Load Balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) provides an Ingress controller that sets up application load balancing

## Overview
Amazon Elastic Kubernetes Service (EKS) is a deployment of upstream Kubernetes on Amazon Web Services infrastructure with integrations into AWS features such as EBSCSI for storage and AWS LoadBalancers for Ingress.  

This is appealing to Konveyor developers as it gives us another Kubernetes environment to test beyond minikube.

## Setup
* One time setup steps so you can use these scripts
### Create `my_override_vars.yml`
* ```
   cp my_override_vars.yml.example my_override_vars.yml
   ```
* Edit `my_override_vars.yml`
  * Change the value of 'my_name' to a unique value with your name to help identify if in a shared AWS account:  Example I use "jmatthews"
  * If needed, edit the 'region_name' or other attributes if you want to customize
  * Note this file is intentionally ignored in git via .gitignore
### Setup python venv with Ansible requirements
* Setup the python venv and install the needed ansible requirements by running:
  ```
  ./init.sh
  ```
    *  This will create a 'env' directory for the python venv which contains Ansible and it's collections installed
       *  If you need to update the venv requirements, run: `pip3 freeze > requirements.txt`
       *  To update the Ansible collections, update `requirements.yml` manually
### AWS Client setup
1. Install the `aws` CLI tool
   * See:  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
1. Install the `eksctl` CLI tool
   * See: https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
1. Configure your AWS credentials so they are available in the shell
   * See: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
1. Verify you are able to run both [aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) from your shell 
   * Example: `aws ec2 describe-instances`
   * Example: `eksctl get clusters`
1. Extras that may be needed
   * In order to be able to run `aws iam help`
     * Ensure you have `groff` installed

## Provision EKS Cluster
Run
```
source env/bin/activate
./create_cluster.sh
```
   * This will take on order of ~20 minutes

## Install software on Cluster
Run
```
source env/bin/activate
./install_software.sh
```
   * This will install:
     * metrics-server
     * test program for dynamic PV provisioning
     * OLM
     * Konveyor 

## Deprovision EKS Cluster
Run 
```
source env/bin/activate
./delete_cluster.sh
```
   * This will take on order of ~10 minutes


# Amazon EKS Documentation
Below may help us as we run into problems or need to learn more on the environment specifics 
* [Amazon Elastic Kubernetes Service Documentation](https://docs.aws.amazon.com/eks/index.html)
  * [EKS Networking](https://docs.aws.amazon.com/eks/latest/userguide/eks-networking.html)
    * [Amazon EKS Best Practices Guide for Networking](https://aws.github.io/aws-eks-best-practices/networking/index/)
    * [Amazon VPC CNI K8S Troubleshooting](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/troubleshooting.md) 
  * [Amazon EKS AddOns](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
    * [Amazon EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
      * Note:  As of ~k8s 1.23 the in tree support for EBS has stopped being used and EBSCSI driver is required for dynamic PV provisioning.
  * [Installing the AWS Load Balancer Controller add-on](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
    * [How AWS Load Balancer controller works](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/how-it-works.md)
    * [Application load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
    * [Network load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)
    * [Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/)
* [eksctl](https://eksctl.io/)
  * [Manage IAM users and roles](https://eksctl.io/usage/iam-identity-mappings/)
  * [IAM Roles for Service Accounts](https://eksctl.io/usage/iamserviceaccounts/)

## Debugging
### AWS Load Balancer
   * Ensure your Ingress has: 
      ```
      spec:
      ingressClassName: alb
      ```
   * aws-load-balancer-controller-* is the pod running the controller in 'kube-system'
      ```
      kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
      ```
   * `internal-*`
  
      If your ingress starts with `internal-` you probably will want to update it to be internet facing by adding this annotation to the Ingress object
      ```
      alb.ingress.kubernetes.io/scheme: internet-facing
      ```
   * If you have a public ingress, but it's not resolving...try waiting a few minutes, I've seen ~5 minute delays before the address the ingress had was accessible.