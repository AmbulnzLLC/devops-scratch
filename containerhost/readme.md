# Push to Instance

Code for two servers

## Devops Server

The devops server should do the following:

* Listen for pull requests
* Create a local branch of the repo that it can build from
* Build (or kick off the build of) the containers
* Push (or kick of the push of) the containers to the ECR
* Launch the container host
* Listen for container host to call home

## Container Host

* Execute call home to devops server, getting container build version
* Replace token in docker-compose with container build version
* Spin up docker instances

## AWS Artifacts Required

* IAM role for devops server
* IAM role for container host

## Future Work Required

* HTTPS
* Autoscaling Group
* Load Balancer
