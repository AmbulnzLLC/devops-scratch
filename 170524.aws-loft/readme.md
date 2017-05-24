# Notes on AWS Pop-Up Loft May 24, 2017

## Autoscaling Triggers

* Our autoscaling triggers should be based on mean latency. 
* Autoscaling policy will only do what we need if we fix pathological queries and health checks.
* The only way to understand the correctness of a new autoscaling policy is to run load testers against the service and make sure it scales correctly. (Amazon does not have out-of-the-box load testers.)

## Health Checks

* Health check should fail as soon as an API server starts returning 5xx-level errors at any time.
* Health checks can be setup on Nginx.

## Database Performance

To handle weird traffic spikes that degrade performance, consider the following:

* Set database volume to GP2 vs provisioned IOPS. GP2 allows for burst use without throttling based on credit system. Provisioned IOPS throttles immediately.
* By default, an RDS instance is provisioned to allow 3 r-w operations per second per provisioned GB of storage. Increasing storage size increases throttling base.

# General Notes

* Our lack of logging is killing our ability to make intelligent decisions about performance and prioritizing fixes.
* Include htop on next generation prinstance-host image.
* Action item: Update readme in JSApps to include information about repeatable migrations.
