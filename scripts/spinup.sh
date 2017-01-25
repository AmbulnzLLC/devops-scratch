aws ec2 run-instances --image-id ami-b7a114d7 --security-group-ids sg-846fa3fc --count 1 --instance-type t2-micro --key-name devops-containers --query 'Instances[0].InstanceId'
"i-ec3e1e2k" 
