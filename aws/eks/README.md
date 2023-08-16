# Create an EKS Cluster
This directory will help you deploy an EKS Cluster with the [EBS CSI AddOn](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) and [Amazon Load Balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) configured.  It relies heavily on the [aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) CLI tools
 * [EBS CSI AddOn](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) allows dynamic PV provisioning
 * [Amazon Load Balancer controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) provides an Ingress controller that sets up application load balancing

## Overview
Amazon Elastic Kubernetes Service (EKS) is a deployment of upstream Kubernetes on Amazon Web Services infrastructure with integrations into AWS features such as EBSCSI for storage and AWS LoadBalancers for Ingress.  

This is appealing to Konveyor developers as it gives us another Kubernetes environment to test beyond minikube.

* Note:  There is an alternative path to getting Konveyor available on an EKS cluster leveraging work from Claranet: https://github.com/claranet-ch/konveyor-eks-blueprint-addon

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
     * Note:  You will want to keep `eksctl` updated so you can deploy new versions of k8s as EKS adopts them.
2. Configure your AWS credentials so they are available in the shell
   * See: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
3. Verify you are able to run both [aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) from your shell 
   * Example: `aws ec2 describe-instances`
   * Example: `eksctl get clusters`
1. Install `jq`
   * https://stedolan.github.io/jq/download/
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

## Adding other IAM users to this EKS cluster
```
source env/bin/activate
./add_users.sh
```
   * This will take on order of ~1 minute
   * It will look up all of the IAM Users in the IAM Group {{ my_eks_usage_iam_group_name }} and add them to "system:masters" on the current configured EKS cluster

* You can confirm who is currently configured for the cluster by looking at:
      ```
      kubectl get configmap aws-auth -n kube-system -o yaml
      ```

## Generating a Kubeconfig
* the `create_cluster.sh` script will generate a kubeconfig, but if you want to generate another kubeconfig for an existing EKS cluster you can run:
```
cd helpers
./write_kubeconfig $clusername $region
```

## Access Konveyor UI
1. export KUBECONFIG=`pwd`/{REPLACE_MYNAME}.kubeconfig
   * Look at your `my_override_vars.yml` and see the name you chose for ```myname```
1. Leverage the ALB Ingress automatically created by the konveyor operator: ```ui_ingress_class_name: "alb"```
   * ```kubectl get ingress -n konveyor-tackle```
      * You could also run a local port-forward if you saw an issue with the Ingress
         * ```kubectl port-forward svc/tackle-ui 7080:8080 -n konveyor-tackle```
         * Then open browser to http://localhost:7080
1. Default login info for first time logging in is defined in https://github.com/konveyor/tackle2-hub/blob/main/auth/users.yaml#L2
   * Username: ```admin```
   * Password: ```Passw0rd!```
1. After successful login it will prompt for a new password for ```admin``` 

## Getting Started with an Analysis
1. Follow an example here:  https://github.com/konveyor/example-applications/blob/main/example-1/README.md

# Amazon EKS Documentation
Below may help us as we run into problems or need to learn more on the environment specifics 
* [Amazon Elastic Kubernetes Service Documentation](https://docs.aws.amazon.com/eks/index.html)
  * [EKS Networking](https://docs.aws.amazon.com/eks/latest/userguide/eks-networking.html)
    * [Amazon EKS Best Practices Guide for Networking](https://aws.github.io/aws-eks-best-practices/networking/index/)
    * [Amazon VPC CNI K8S Troubleshooting](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/troubleshooting.md) 
  * [Amazon EKS AddOns](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
    * [Amazon EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
      * Note:  As of ~k8s 1.23 the in tree support for EBS has stopped being used and EBSCSI driver is required for dynamic PV provisioning.
  * [How does AWS IAM Authenticator work?](https://github.com/kubernetes-sigs/aws-iam-authenticator#how-does-it-work)
    * As of April 2023 it's not possible to map an IAM Group to an EKS cluster
      * Open issue in [kubernetes-sigs/aws-iam-authenticator: Can I not add an IAM group to my ConfigMap? #176](https://github.com/kubernetes-sigs/aws-iam-authenticator/issues/176)
      * Deep dive and workaround:  [Enabling AWS IAM Group Access to an EKS Cluster Using RBAC](https://eng.grip.security/enabling-aws-iam-group-access-to-an-eks-cluster-using-rbac)
  * [Installing the AWS Load Balancer Controller add-on](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
    * [How AWS Load Balancer controller works](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/how-it-works.md)
    * [Application load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
    * [Network load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)
    * [Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/)
* [eksctl](https://eksctl.io/)
  * [Manage IAM users and roles](https://eksctl.io/usage/iam-identity-mappings/)
  * [IAM Roles for Service Accounts](https://eksctl.io/usage/iamserviceaccounts/)

## Debugging
### Check that dynamic PV Provisioning is working for the cluster
* Provisioning PVC's with RWO is supported via the ebscsi driver, there is a sample app deployed 
   ```
   $ kubectl get pvc ebs-claim -n testebs
   NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   ebs-claim   Bound    pvc-2b6e1543-ef3d-42e6-aa63-d7f5cd2f5970   4Gi        RWO            gp2            3d7h
   ```
* We could configure RWX support via EFS but that is not configured as of now
### Check that Ingress is working the cluster
* Ingress via the Amazon Load Balancer controller is configured with sample app 'game-2048'
   ```
   $ kubectl get ingress -n game-2048
   NAME           CLASS   HOSTS   ADDRESS                                                                  PORTS   AGE
   ingress-2048   alb     *       k8s-game2048-ingress2-5590c303a6-822812758.us-east-1.elb.amazonaws.com   80      3d7h
   ```
### AWS Load Balancer
   * aws-load-balancer-controller-* is the pod running the controller in 'kube-system'
      ```
      kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
      ```
   * Ensure your Ingress has: 
      ```
      spec:
      ingressClassName: alb
      ```
   * `internal-*`
      If your ingress starts with `internal-` you probably will want to update it to be internet facing by adding this annotation to the Ingress object
      ```
      alb.ingress.kubernetes.io/scheme: internet-facing
      ```
   * If your Service is using a ClusterIP you will need below annotation
      ```
      alb.ingress.kubernetes.io/target-type: ip
      ```
        * Impression is ALB likes to work with NodePort by default
        * Without the annotation and using ClusterIP in the service I saw below error
            ```
            kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

            {"level":"error","ts":1681061324.959598,"logger":"controller.ingress","msg":"Reconciler error","name":"tackle","namespace":"konveyor-tackle","error":"InvalidParameter: 1 validation error(s) found.\n- minimum field value of 1, CreateTargetGroupInput.Port.\n"}
            ```
   * If you have a public ingress, but it's not resolving...try waiting a few minutes, I've seen ~5 minute delays before the address the ingress had was accessible.
