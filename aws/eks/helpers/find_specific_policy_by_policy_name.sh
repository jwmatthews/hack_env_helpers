# Find a specific Policy by 'PolicyName'
#  I didn't see a way to to this directly from 'aws' CLI or 
#  - https://docs.ansible.com/ansible/latest/collections/amazon/aws/iam_policy_module.html#ansible-collections-amazon-aws-iam-policy-module
#  - https://docs.ansible.com/ansible/latest/collections/amazon/aws/iam_policy_info_module.html#ansible-collections-amazon-aws-iam-policy-info-module

#aws iam list-policies | python -c 'import json,sys;data=json.load(sys.stdin)["Policies"];obj=filter(lambda x: (x["PolicyName"] == "AWSLoadBalancerControllerIAMPolicy"), data); print(list(obj))';
aws iam list-policies | python -c 'import json,sys;data=json.load(sys.stdin)["Policies"];obj=filter(lambda x: (x["PolicyName"] == "AWSLoadBalancerControllerIAMPolicy"), data); found=list(obj); print(found[0]["Arn"]) if len(found) > 0 else print("");';

# Expected format of data from "aws iam list-policies"
#{
#    "Policies": [
#        {
#           "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
#           "Arn": "arn:aws:iam::346869059911:policy/AWSLoadBalancerControllerIAMPolicy",
#






