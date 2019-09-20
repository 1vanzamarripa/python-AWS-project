#!/bin/bash
### AWS CLI SETUP
aws configure

### STACK SETUP
#create cloudformation stack using Ansible
#ansible-playbook ansible/cloudformation.yml 
echo "Please enter your EC2 Key Pair name"
read KEY_PAIR_NAME
echo "Please enter a Password for the RDS DB"
read -s RDS_DB_PASS
TEMPLATE_PATH="ansible/roles/cloudformation/files"
aws cloudformation deploy \
  --template-file ${TEMPLATE_PATH}/environment.yml \
  --stack-name DevopsHomework \
  --parameter-overrides KeyName=${KEY_PAIR_NAME} DatabasePassword=${RDS_DB_PASS} \
  --capabilities CAPABILITY_IAM

### EKS SETUP
#obtaining EKS cluster credentials and saving in ~/.kube/config
rm -rf ~/.kube && aws eks --region us-east-1 update-kubeconfig --name HomeworkCluster
#making sure worker nodes can join the cluster
#https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
rm -rf aws-auth-cm.yaml
git checkout -- aws-auth-cm.yaml
NODE_INSTANCE_ROLE=$(aws iam list-roles --query 'Roles[?contains(Arn, `NodeInstanceRole`) == `true`].[Arn]' | grep "arn")
sed -i "s|<NodeInstanceRoleArn>|$NODE_INSTANCE_ROLE|g" aws-auth-cm.yaml
kubectl apply -f aws-auth-cm.yaml
#waiting for nodes to join before applying namespace config
sleep 30 && kubectl apply -f namespace.yml

### RDS SETUP
#This script will create a k8s job that will initialize the RDS DB with data
cd sql-job && ./build.sh $RDS_DB_PASS 
cd -

### ALB INGRESS CONTROLLER SETUP
#create the policy
#curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/iam-policy.json
#ROLE_POLICY_ARN=$(aws iam create-policy \
#  --policy-name ALBIngressControllerIAMPolicy \
#  --policy-document file://iam-policy.json \
#  | grep "arn" | awk '{print $2}' | sed s/\"//g | sed s/,//g)
#NODE_INSTANCE_ROLE_NAME=$(echo $NODE_INSTANCE_ROLE | awk 'BEGIN { FS="/" } /1/ { print $2 }' | sed s/\"//g )
#aws iam attach-role-policy --policy-arn $ROLE_POLICY_ARN --role-name $NODE_INSTANCE_ROLE_NAME
#rm -rf iam-policy.json
#create a service account, cluster role, and cluster role binding for the ALB Ingress Controller to use
#kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/rbac-role.yaml
#deploy the ALB Ingress Controller
#kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.2/docs/examples/alb-ingress-controller.yaml
#open the ALB Ingress Controller deployment manifest for editing with the following command
#kubectl get deployment.apps/alb-ingress-controller -n kube-system -o json > alb-ingress-controller.json
