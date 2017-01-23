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

If any changes have been make to docker-compose-sandbox.yaml in the JSApps 
repository since the last deployment, you'll need to create a new task 
definition in ECS. 

Before you do so, open [the task definition page for ecscompose-JSApps](
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/taskDefinitions/ecscompose-JSApps/status/ACTIVE) 
and make a note of the last revision number. Then, navigate to the project 
directory and type:
   
```ecs-cli compose --file docker-compose-sandbox.yaml create```

**Checkpoint**: Refresh the task definition page. If a new revision has appeared,
 task was created successfully. If a new revision hasn't appeared, 
 but no errors occurred, the new task is most likely identical to the
 old task and no new revision number was added.
 
## Step 4: Create ECS Container Cluster

If you have an existing ecs cluster you'd like to use, you can skip this step. Otherwise,
you'll need to edit your ~/.ecs/config file to change the name of the target cluster you
want to create (current naming standard is jsapps-sandbox-*jiraticketnumber*.)

Once that's done, execute the following line:

```ecs-cli up  --size 1 --instance-type m4.large --verbose --keypair devops-containers --capability-iam --security-group sg-f3b8718b --vpc vpc-087ecb6f --subnets subnet-89a04cc0, subnet-25a16b42```

(If you don't have the *.pem key for devops-containers, you'll need to generate and 
use
another key with Amazon's IAM service or you won't be able to ssh into your container hosts later.)

In the future, if you're creating a new environment, it's important that your security
group exists in the same VPC as your container hosts. Also, the subnet IDs are 
unique to the VPC you choose. Select vpc-087ecb6f and add both subnets.

Bringing the stack up can take several minutes, during which you can start on
step 5.

**Checkpoint**: With the verbatim flag passed, the command-line tool will report
back on success most of the time. Sometimes, the cli will hang or loop on creating
the ECS instance auto-scaling group, but the stack will actually be created correctly.

You can confirm the existence of your cluster on the [ECS clusters page](
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/clusters).
If the cli glitches, you can determine the success of stack creation by 
proceeding to step 6.


## Step 5: Create Target Groups

In order for your load balancer to correctly target all three services with both HTTP and HTTPS, it will require a 
number of target groups. These are created in the [Target Group Console](
https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#TargetGroups:).

Each load balancer requires eight target groups - one set of four for HTTP and
 one for HTTPS. These will be routes for: 
 
 * the webrequester at /
 * the relay server at /socket.io
 * the REST server at /api
 * an additional entry for the REST server at /catalog (TODO: Correct this.)

Each target group must be created on the correct vpc (vpc-087ecb6f) and
listen on either port 80 or port 443. The health check is / (root) for the
 webrequester and /health for the other security groups. All health requests
  should be on the HTTP protocol regardless of the listening protocol.
 The advanced health check settings can be left on their defaults.

In order to be able to find these later, I name them jiranumber(rev)-protocol-path-tg.
For example, the root path target group for the sixth revision of the work
done for ticket AM-1058 is 1058f-http-root-tg. 

## Step 6: Construct a Load Balancer

Navigate to the [AWS EC2 control panel](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2), navigate to load balancers, and create a load balancer.
On the first screen of the wizard, select "Application Load Balancer"
and place the new ALB in the same VPC as you used to set up the ECS cluster. 
If you've followed these instructions to this point, that will be vpc-087ecb6f.
Add all three subnets to the availability list.

Add listeners for both HTTP and HTTPS. and add both subnets.  Whatever you name your load 
balancer, make a note of the name for later. 

Under "Configure Security Settings," leave the defaults.

Under "configure security groups," select the group called "csg-jsapps-containers."
Skip registering targets for now. 
ECS will register them for us.

For routing, choose "existing target group" and select the root http
target group you created in the previous step. Leave the other fields
on their defaults. Then, click through to the end.

## Step 7: Add Target Groups to Load Balancer

Once your load balancer is provisioned and created, navigate to the
[load balancer console](
https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#LoadBalancers:)
and select your new load balancer. In the listeners tab, open the
HTTP and HTTPS listener and add a rule for each HTTP and HTTPS target group you created.
Point he HTTPS default rule to the https-root target group. The relay
target groups should be on path /socket.io. Catalog and api should be on /catalog
and /api respectively.

## Step 8: Start Your Service

TODO: Use routes with wildcards, not just "/api," but "/api/*"

Once steps 2-7 are completed successfully, navigate to the 
[ECR Container Cluster page](
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/clusters) 
and find your new cluster. Click Service -> Create.

The task definition is the highest tagged number of 
ecs-compose-JSApps (currently ecs-compose-JSApps:10.) 
Set the number of tasks to 1 and make a note of the name you give the service.

Click "Configure ELB." Select your load balancer by name. For "select a container," choose
"webrequester:5600." Set your port to 80 (HTTP) and select the main 
target group you created earlier. Create the service with 1 task.

**Checkpoint**: At this point, you'll be able to check whether or not
the service is up and running correctly using the following processes:

* **SSH into your EC2 Instance**: Using the pem file you refrerenced in step 4,
 connect to the EC2 instance created to host your containers, run ```docker ps```,
 and confirm that the three services are running.
* **Request port 5000/health on your host instance**: If your host IP address
is 35.167.237.93, request GET http://35.167.237.93:5000/health. You should get
a response including "OK." This is the relay server.
* **Request port 5100/health on your host instance**: If your host IP address
is 35.167.237.93, request GET http://35.167.237.93:5100/health. You should get
a response including "OK." This is the API server.
* **Navigate to port 5600 on your host instance**: In a browser, navigate to
 http://&lt;instance-ip-address&gt;:5600. If the front page of the webrequester appears,
 the server is running correctly and exposing the ports as expected. If the page fails
 to load, but updates the address protocol to https, the service is running, but
  something else is wrong.
* **Navigate to the public DNS of your load balancer**: If everything is correctly configured,
the protocol should automatically switch to https and you should be able to log into the web
requester from here. (Security errors on https here are correct and normal.)
 
## Step 9: Map Your Domain to Route 53

Login to the [Route 53 control panel for ambulnz-dev.com](https://console.aws.amazon.com/route53/home?region=us-west-2#resource-record-sets:ZQX48K9VKMJTV). Create a new A-Type recordset and make a note of the name. Set alias to true and point the alias to your load balancer.
 
If everything works correctly, you should now be able to navigate to your new domain
and login to the web requester using credentials from the sandbox environment.

## Coda: Cleaning up assets

When you're done with your installation, you can clear up the 
expensive assets created by doing the following:
 
* update the service you created to have a desired task count of zero.
* update the auto-scaling group to have 0 minimum, maximum, and desired tasks.
* once you've confirmed the EC2 instance you created is terminated, delete the ASG.
* delete the ECS cluster. This will also delete its CloudFormation stack.

For a full clean-up, you can also delete the 
load balancer, target groups, and DNS A record you created 
(providing you haven't shared them with other services.)

## Update History
* 23-Jan-2017 - Remove HTTP/HTTPS confusion
* 11-Jan-2017 - Update information about load balancer / target groups
* 5-Jan-2017 - Initial document

