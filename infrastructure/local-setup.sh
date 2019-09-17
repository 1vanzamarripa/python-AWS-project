#!/bin/bash
### AWS CLI SETUP
aws configure

### STACK SETUP
#create cloudformation stack using Ansible
#ansible-playbook ansible/cloudformation.yml 
echo "Please enter your EC2 Key Pair name"
read KEY_PAIR_NAME
echo "Please enter a Password for the RDS DB"
read RDS_DB_PASS
TEMPLATE_PATH="ansible/roles/cloudformation/files"
aws cloudformation deploy \
  --template-file ${TEMPLATE_PATH}/environment.yml \
  --stack-name DevopsHomework \
  --parameter-overrides KeyName=${KEY_PAIR_NAME} DatabasePassword=${RDS_DB_PASS} \
  --capabilities CAPABILITY_IAM

### RDS SETUP
DB_PASSWORD=$(echo $RDS_DB_PASS | base64)
sed -i "s|<DB_PASSWORD>|$DB_PASSWORD|g" ../hardware/k8s/hardware-secret.yml

### EKS SETUP
#obtaining EKS cluster credentials and saving in ~/.kube/config
aws eks --region us-east-1 update-kubeconfig --name HomeworkCluster
#making sure worker nodes can join the cluster
#https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
NODE_INSTANCE_ROLE=$(aws iam list-roles --query 'Roles[?contains(Arn, `NodeInstanceRole`) == `true`].[Arn]' | grep arn)
sed -i "s|<NodeInstanceRoleArn>|$NODE_INSTANCE_ROLE|g" aws-auth-cm.yaml
kubectl apply -f aws-auth-cm.yaml

