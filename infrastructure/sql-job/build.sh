#!/bin/bash
TIMESTAMP=`date +%y%m%d%H%M%S`
K8S_DIR="k8s"
DB_PASSWORD=$(echo $1 | base64)
DB_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier hardwareavailability \
  --query 'DBInstances[*].[Endpoint]' \
  | grep "Address" | awk '{print $2}' | sed s/\"//g  | base64 -w 0)

echo "Please enter your docker repository name in Docker Hub"
read DOCKER_REPO
echo "Please login to Docker Hub"
docker login
docker build -t $DOCKER_REPO/sql-job:$TIMESTAMP .
docker push $DOCKER_REPO/sql-job:$TIMESTAMP

rm -rf $K8S_DIR/db-secret.yml
git checkout -- $K8S_DIR/db-secret.yml
rm -rf $K8S_DIR/db-init-job.yml
git checkout -- $K8S_DIR/db-init-job.yml

sed -i "s|<DB_PASSWORD>|$DB_PASSWORD|g" $K8S_DIR/db-secret.yml
sed -i "s|<DB_ENDPOINT>|$DB_ENDPOINT|g" $K8S_DIR/db-secret.yml
sed -i "s|<DOCKER_REPO>|$DOCKER_REPO|g" $K8S_DIR/db-init-job.yml
sed -i "s|<DOCKER_TAG>|$TIMESTAMP|g" $K8S_DIR/db-init-job.yml

kubectl apply -f $K8S_DIR/db-secret.yml
kubectl apply -f $K8S_DIR/db-init-job.yml
