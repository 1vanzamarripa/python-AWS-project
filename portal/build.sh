#!/bin/bash
TIMESTAMP=`date +%y%m%d%H%M%S`
K8S_DIR="k8s"
echo "Please enter your docker repository name in Docker Hub"
read DOCKER_REPO
echo "Please login to Docker Hub"
docker login
docker build -t $DOCKER_REPO/portal:$TIMESTAMP .
docker push $DOCKER_REPO/portal:$TIMESTAMP

rm -rf k8s/portal-deployment.yml
git checkout -- k8s/portal-deployment.yml
sed -i "s|<DOCKER_REPO>|$DOCKER_REPO|g" k8s/portal-deployment.yml
sed -i "s|<DOCKER_TAG>|$TIMESTAMP|g" k8s/portal-deployment.yml

kubectl apply -f $K8S_DIR/portal-deployment.yml
kubectl apply -f $K8S_DIR/portal-service.yml
#kubectl apply -f $K8S_DIR/portal-ingress.yml
