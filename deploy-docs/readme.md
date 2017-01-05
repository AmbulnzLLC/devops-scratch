# Deploying Ambulnz Web Components

## Overview

This document describes the process required to manually deploy the api, relay, and 
web requester components of the Ambulnz suite of applications. Environment-specific
variables refer to the "sandbox" environment.

The components are deployed to the AWS (Amazon Web Services) cloud using EC2 
(Elastic Compute Cloud) instances and the 
EC2 Container Service (ECS).

## Prerequisites
The assumption made in this documentation is that the user is working on a MacBook running a reasonably modern Darwin-based OS (MacOS) 
configured to build and run Ambulnz's suite of node apps. See the main project readme for details.
  
Additionally, the following should be installed:

* [The AWS command-line tool](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [The Elastic Container Service command-line tool](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
* [Docker](https://docs.docker.com/docker-for-mac/)
* An Amazon EC2 keypair registered to Ambulnz

The command-line tools need to be configured with an AWS IAM keypair that has full permissions on EC2, ECS, CodeCommit, CodeBuild, and CloudFormation. (Generally, a full-admin key is recommended.)

## Step 1: Github to Amazon

When a code branch of the [JSApps repository](https://github.com/AmbulnzLLC/JSApps) on github is ready to be deployed into
a sandbox environment, it can be pushed to the Amazon CodeCommit service. To do so, you need the Amazon endpoint available as a remote. To add
the current repository, navigate to the directory where you're tracking JSApps and type:

```git remote add amazon ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/ambulnz-jsapps```

You can then push your code branch to CodeCommit using the git cli:

```git push amazon feature/AM-xxx/fixBrokenThing```

## Step 2: Code to Containers

There is a build project set up in [Amazon Code Build](https://us-west-2.console.aws.amazon.com/codebuild/home?region=us-west-2#/projects) called js-servicecontainers. Using the branch
you just pushed, start the build process. This will create the containers needed to run the service sandbox and store them in the [Amazon Elastic Container Registry](https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/repositories).
The build process can take up to 20-30 minutes. While the build is running, you can continue with steps 3 and 4.

## Step 3: Convert Docker Compose File to ECS Task

If any changes have been make to docker-compose-sandbox.yaml in the JSApps repository since the last deployment, you'll need to create a new task definition in
 ECS. To do so, navigate to the project directory and type:
  
```ecs-cli compose --file docker-compose-sandbox.yaml create```

## Step 4: Create ECS Container Cluster

If you have an existing ecs cluster you'd like to use, you can skip this step. Otherwise,
you'll need to edit your ~/.ecs/config file to change the name of the target cluster you
want to create (current naming standard is jsapps-sandbox-*jiraticketnumber*.)

Once that's done, execute the following line:

```ecs-cli up --verbose --keypair devops-containers --capability-iam --security-group sg-f3b8718b --vpc vpc-087ecb6f --subnets subnet-89a04cc0, subnet-25a16b42 --size 1 --instance-type m4.large ```

**A Note on IDs**: If you're creating a new environment, it's important that your security
group exists in the same VPC as your container hosts. Also, the subnet IDs are unique to the VPC you choose.

## Update History
* 5-Jan-2017 - Initial document

