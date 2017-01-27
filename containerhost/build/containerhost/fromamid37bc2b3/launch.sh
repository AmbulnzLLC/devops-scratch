#! /bin/bash


$(aws ecr get-login --region us-west-2)
docker-compose up
