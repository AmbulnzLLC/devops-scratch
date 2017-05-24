# Notes on AWS Pop-Up Loft May 24, 2017

## Autoscaling Triggers

## Health Checks

## Database Performance

To handle weird traffic spikes that degrade performance, consider the following:

* Set database volume to GP2 vs provisioned IOPS. GP2 allows for burst use without throttling based on credit system. Provisioned IOPS throttles immediately.
