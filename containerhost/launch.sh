#! /bin/sh

sed -s 's/replacethis/%1/g' docker-compose.yaml
docker-compose start
