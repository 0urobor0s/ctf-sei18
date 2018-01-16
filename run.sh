#!/bin/bash

# 1
cd 1.\ Flag/
docker-compose up
cd ..

# 5
cd 5.\ FTP/
docker-compose build
docker-compose up

# 8
cd 8.\ RCE/server/railsV/
docker-compose build
docker-compose up
cd ..