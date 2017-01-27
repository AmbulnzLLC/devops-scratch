#! /bin/bash
sed -i 's/replacethis/%1/g' docker-compose.yaml

$(aws ecr get-login --region us-west-2)
docker-compose up
