# Deploying Ambulnz Web Components

## Overview

This document describes the process required to manually deploy the api, relay, and 
web requester components of the Ambulnz suite of applications. Environment-specific
variables refer to the "sandbox" environment.

The components are deployed to the AWS (Amazon Web Services) cloud using EC2 
(Elastic Compute Cloud) instances and the 
EC2 Container Service (ECS).

## Step 1: Github to Amazon

When a code branch of the [JSApps repository](https://github.com/AmbulnzLLC/JSApps) on github is ready to be deployed into
a sandbox environment, it can be pushed to the Amazon CodeCommit service. To do so, you need the Amazon endpoint available as a remote. To add
the current repository, navigate to the directory where you're tracking JSApps and type:

```git remote add amazon ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/ambulnz-jsapps```

You can then push your code branch to CodeCommit using the git cli:

```git push amazon feature/AM-xxx/fixBrokenThing```

## Update History
* 5-Jan-2017 - Initial document

