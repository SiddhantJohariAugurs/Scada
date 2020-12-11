#!/bin/bash
docker volume create scada-lts_data
docker run --name scada-lts-db -d -p 3306:3306 -v scada-lts_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=scadalts mysql:5.7.27