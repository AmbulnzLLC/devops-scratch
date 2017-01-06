# Deploying Ambulnz Web Components

## Overview

This document describes the process required to manually deploy the api, relay, 
and  web requester components of the Ambulnz suite of applications. 
Environment-specific variables refer to the "sandbox" environment.

The components are deployed to the AWS (Amazon Web Services) cloud using EC2 
(Elastic Compute Cloud) instances and the EC2 Container Service (ECS).

## Prerequisites
The assumption made in this documentation is that the user is working on a 
MacBook running a reasonably modern Darwin-based OS (MacOS) configured to 
build and run Ambulnz's suite of node apps. See the main project readme 
for details.
  
Additionally, the following should be installed:

* [The AWS command-line tool](
http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [The Elastic Container Service command-line tool](
http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
* [Docker](
https://docs.docker.com/docker-for-mac/)
* An Amazon EC2 keypair registered to Ambulnz

The command-line tools need to be configured with an AWS IAM keypair that has 
full permissions on EC2, ECS, CodeCommit, CodeBuild, and CloudFormation. 
(Generally, a full-admin key is recommended.)

## Step 1: Github to Amazon

When a code branch of the [JSApps repository](
https://github.com/AmbulnzLLC/JSApps) on github is ready to be deployed into
a sandbox environment, it can be pushed to the Amazon CodeCommit service. To 
do so, you need the Amazon endpoint available as a remote. To add
the current repository, navigate to the directory where you're tracking 
JSApps and type:

```git remote add amazon ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/ambulnz-jsapps```

You can then push your code branch to CodeCommit using the git cli:

```git push amazon feature/AM-xxx/fixBrokenThing```

**Checkpoint**: You can confirm this code was pushed successfully by navigating
to [the commits tab of the CodeCommit repo](
https://us-west-2.console.aws.amazon.com/codecommit/home?region=us-west-2#/repository/ambulnz-jsapps/commits/master),
selecting the branch you pushed, and confirming that your most recent 
commits have been added.

## Step 2: Code to Containers

There is a build project set up in [Amazon Code Build](
https://us-west-2.console.aws.amazon.com/codebuild/home?region=us-west-2#/projects)
called js-servicecontainers. Using the branch you just pushed, start the build 
process. This will create the containers needed to run the service sandbox and 
store them in the [Amazon Elastic Container Registry](
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/repositories).
The build process can take up to 20-30 minutes. While the build is running, you 
can continue with steps 3 and 4.

**Checkpoint**: To confirm that the build completed without error, navigate to
[The Build History tab of the js-servicecontainers CodeBuild project](
https://us-west-2.console.aws.amazon.com/codebuild/home?region=us-west-2#/builds).
Your build run should read "Succeeded."

To confirm that the containers were updated and uploaded to the Elastic Container 
Registry correctly, check on the repos for the [REST server](
https://us-west-2.console.aws.amazon.com/codebuild/home?region=us-west-2#/builds
), [relay](
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/repositories/ambulnz-relay#images;tagStatus=ALL),
and [webrequester](https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/repositories/nanolnz-webclient#images;tagStatus=ALL)
containers. Confirm that their current build occurred at the expected time. 

## Step 3: Convert Docker Compose File to ECS Task

If any changes have been make to docker-compose-sandbox.yaml in the JSApps repository since the last deployment, you'll need to create a new task definition in
 ECS. To do so, navigate to the project directory and type:
  
```ecs-cli compose --file docker-compose-sandbox.yaml create```

## Step 4: Create ECS Container Cluster

If you have an existing ecs cluster you'd like to use, you can skip this step. Otherwise,
you'll need to edit your ~/.ecs/config file to change the name of the target cluster you
want to create (current naming standard is jsapps-sandbox-*jiraticketnumber*.)

Once that's done, execute the following line:

```ecs-cli up  --size 1 --instance-type m4.large --verbose --keypair devops-containers --capability-iam --security-group sg-f3b8718b --vpc vpc-087ecb6f --subnets subnet-89a04cc0, subnet-25a16b42```

(If you don't have the *.pem key for devops-containers, you'll need to generate and 
use
another key with Amazon's IAM service or you won't be able to ssh into your container hosts later.)

**A Note on IDs**: If you're creating a new environment, it's important that your security
group exists in the same VPC as your container hosts. Also, the subnet IDs are unique to the VPC you choose. Select vpc-087ecb6f and add both subnets.

## Step 5: Create a Load Balancer

Navigate to the [AWS EC2 control panel](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2), navigate to load balancers, and create a load balancer.
On the first screen of the wizard, select "Application Load Balancer."

Whatever you name your load balancer, make a note of the name for later. Make sure you have HTTP and HTTPS listeners.
Leave the defaults under "Configure Security Settings."

Under "configure security groups," select the group called "csg-jsapps-containers." Create a new target group for the HTTPS protocol and make a note of the name you give it. Skip registering targets for now. ECS will register them for us.

## Step 6: Start Your Service

Once steps 2-4 are completed successfully, navigate to the [ECR Container Cluster page](https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/clusters) and find your new cluster. Click Service->Create.

The task definition is the highest tagged number of ecs-compose-JSApps (currently ecs-compose-JSApps:8.) Set the number of tasks to 1 and make a note of the name you give the service.

Click "Configure ESB." (**Note**: this section will need to be rewritten to allow traffic to all three containers.) Select your load balancer by name. Set your port to 443 (HTTPS) and select the target group you created earlier. Create the service.

## Step 7: Map Your Domain to Route 53

Login to the [Route 53 control panel for ambulnz-dev.com](https://console.aws.amazon.com/route53/home?region=us-west-2#resource-record-sets:ZQX48K9VKMJTV). Create a new A-Type recordset and make a note of the name. Set alias to true and point the alias to your load balancer.
 
If everything works correctly, you should now be able to navigate to your new domain.

## Coda: Cleaning up assets

When you're done with your installation, you can clear up the expensive assets created by navigating to the service you created in the ECS console
and updating it to have a task count of zero. Once the service is stopped, you can delete the cluster, which will also delete the EC2 instances used and the CloudFormation stack.
 
 For a full clean-up, you can also delete the load balancer, target group, and DNS A record you created (providing you haven't shared them with other services.)

## Update History
* 5-Jan-2017 - Initial document
