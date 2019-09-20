#!/bin/bash
### AWS CLI SETUP
#aws configure

#re checking out needed config files
rm -rf aws-auth-cm.yaml
git checkout -- aws-auth-cm.yaml
rm -rf sql-job/k8s/db-secret.yml
git checkout -- sql-job/k8s/db-secret.yml

#deleting elb to avoid stack deletion problems
kubectl delete -f ../portal/k8s/portal-service.yml

### STACK DESTRUCTION
aws cloudformation delete-stack --stack-name DevopsHomework