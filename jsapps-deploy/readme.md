# Deploy Scripts for JS-Apps

## Summary

These are the HCL scripts for spinning up a new cluster in Amazon Container Service from a set of Docker containers.

## Prerequisites

In this iteration, the scripts can be once a developer has:

* Pushed their code changes to Amazon CodeCommit
* Built the docker containers for webrequester, relay, and api servers
* Pushed those containers to Amazon's Elastic Container Registry
* Created a container task from the docker-compose file

For details on how to complete these prerequisites, see the [working documentation for cloud deployment](https://github.com/AmbulnzLLC/devops-scratch/tree/develop/deploy-docs).

## Components

These scripts build the following components:

* Virtual Private Cloud
* Subnets
* Security Groups for the containers, the container host, and the load balancer
* ECS Cluster
* ECS Service
* EC2 Instance
* Application Load Balancer
* Load Balancer Rules
* Target Groups
* Route53 Domain Entry
