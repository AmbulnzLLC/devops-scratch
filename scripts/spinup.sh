aws ec2 run-instances --image-id ami-b7a114d7 --security-group-ids sg-846fa3fc --count 1 --instance-type t2.micro --key-name devops-containers --query 'Instances[0].InstanceId'
aws ec2 create-tags --resources i-0c354053b5857abf6 --tags "Key=Name, Value=onetinyinstance"
 
ssh -i "devops-containers.pem" ubuntu@ec2-50-112-30-126.us-west-2.compute.amazonaws.com
wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone us-west-2a
