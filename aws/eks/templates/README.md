# Background Information

## aws-load-balancer-controller_v2_4_7_full.yaml.j2
  * Downloaded originally from: 
    * https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml
  * We need to remove the ServiceAccount definition of 
```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  ```
  * Then we need to make the '--cluster-name=your-cluster-name` from the Deployment templatized
```
    spec:
      containers:
      - args:
        - --cluster-name=your-cluster-name
        - --ingress-class=alb
        image: public.ecr.aws/eks/aws-load-balancer-controller:v2.4.7
```

