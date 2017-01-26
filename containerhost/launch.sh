#! /bin/sh

sed -s 's/latest/%1/g' docker-compose.yaml
docker-compose start
