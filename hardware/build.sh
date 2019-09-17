#!/bin/bash

K8S_DIR="k8s"
echo "Please enter your docker repository name in Docker Hub"
read DOCKER_REPO
echo "Please login to Docker Hub"
docker login
docker build -t $DOCKER_REPO/hardware:latest .
docker push $DOCKER_REPO/hardware:latest 

sed -i "s|<DOCKER_REPO>|$DOCKER_REPO|g" k8s/hardware-deployment.yml

kubectl apply -f $K8S_DIR/hardware-secret.yml
kubectl apply -f $K8S_DIR/hardware-deployment.yml
kubectl apply -f $K8S_DIR/hardware-service.yml
