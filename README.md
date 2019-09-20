# python-AWS-project
## Overview
This project creates AWS infrastructure using a cloudformation script. This script will 
- generate a VPC with private and public subnets and their respective attachments and associations
- an EKS cluster control plane in the public subnet and worker nodes in the private subnet
- a RDS postgres database
It also contains code and configuration for a couple of applications, named portal and hardware, as well as code to create and deploy a k8s job that populates the RDS database at stack creation time.

## Prerrequisites
- aws cli https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html
- docker https://docs.docker.com/install/
- kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl/

### Optional
- ansible
- a Jenkins instance with the k8s plugin installed and configured

## Usage
### Create the infrastructure
To create the whole infrastructure in aws needed for the apps to run, simply execute this script:

```
cd infrastructure
./create-stack.sh
```

You will be prompted for your AWS credentials (Access key and Secret key), the keyPair to use for ssh access into the worker nodes, and the RDS database credentials that you wish to set up.
The script also sets up your k8s credentials locally for kubectl.
Finally it runs a script that creates and pushes a docker image that gets pulled by a k8s job. The purpose of the k8s job is to populate the DB with data needed for the app to work. For the job to access the DB, a k8s secret is created in the cluster with the DB password and the DB endpoint.

To destroy the stack:

```
cd infrastructure
./delete-stack.sh
```

NOTE: There are optional ansible scripts included with this repo, that could be used to create the cloudformation stack only, and then you could configure your AWS stack manually once it is created. to run the scripts:
```
cd infrastructure/ansible
ansible-playbook cloudformation.yml --extra-vars "aws_access_key=xxx aws_access_key=yyy"
```
To destroy the stack using ansible:
```
cd infrastructure/ansible
ansible-playbook cloudformation.yml --extra-vars "aws_access_key=xxx aws_access_key=yyy create=False remove=True"
```

###  Deploy the apps
Both the hardware and the portal python applications can be deployed by running these scripts:

```
cd hardware
./build.sh
```

```
cd portal
./build.sh
```
The build scripts create a docker image containing the python dependencies needed for each app (therefore you will be prompted for your docker hub repo name and authentication), and then the images are pushed to your docker hub repo. Then, the k8s manifests are modified in such a way that enables them to pull the new image.

The k8s objects that get created are: a deployment and a service for each app, and for portal a load balancer type of service gets creaed so the app can be accessed from the internet.

In order to find out the ALB endpoint to hit, run this command:
```
kubectl get svc -n homework 
```

### EXTRA CREDIT:

- The hardware.py script was modified to make use of multiprocessing, a pool of 5 threads was created in order to call the slow simulated function concurrently and reducing the amount of time it takes to get the data.
- The Node group used to create the eks cluster is an auto scaling group.
