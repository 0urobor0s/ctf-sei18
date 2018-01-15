#!/bin/bash

# 1
cd 1.\ Flag/
docker-compose up
cd ..

# 8
cd 8.\ RCE/server/railsV/
docker-compose build
docker-compose up
cd ..