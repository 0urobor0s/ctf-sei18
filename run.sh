#!/bin/bash

# 1
cd 1.\ Flag/
docker-compose up
cd ..

# 3
cd 3.\ MySQL/
docker-compose up
mysql --host=127.0.0.1 -u root --password=chocolate < criation.sql
cd ..

# 4
cd 4.\ Torrent/
docker-compose up
cd ..

# 5
cd 5.\ FTP/
docker-compose build
docker-compose up

#6
cd 6.\ irc\ bot/
./run.sh
cd ..

# 8
cd 8.\ RCE/server/railsV/
docker-compose build
# docker-compose run --rm app bundle exec rake db:create RAILS_ENV=production
docker-compose up
cd ..