#! /bin/sh

sed -s 's/replacethis/am-0000/g' docker-compose.yaml
docker-compose start
