#!/bin/bash
TIMESTAMP=`date +%y%m%d%H%M%S`
K8S_DIR="k8s"
echo "Please enter your docker repository name in Docker Hub"
read DOCKER_REPO
echo "Please login to Docker Hub"
docker login
docker build -t $DOCKER_REPO/sql-job:$TIMESTAMP .
docker push $DOCKER_REPO/sql-job:$TIMESTAMP

rm -rf k8s/db-init-job.yml
git checkout -- k8s/db-init-job.yml
sed -i "s|<DOCKER_REPO>|$DOCKER_REPO|g" k8s/db-init-job.yml
sed -i "s|<DOCKER_TAG>|$TIMESTAMP|g" k8s/db-init-job.yml

kubectl apply -g $K8S_DIR/db-secret.yml
kubectl apply -f $K8S_DIR/db-init-job.yml
