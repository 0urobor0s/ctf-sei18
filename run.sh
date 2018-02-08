#!/bin/bash

# 1
cd 1.\ Flag/
docker-compose up -d
cd ..

# 2
cd 2.\ SQLi/
# chmod +x db-s/insert.sh
docker-compose up --build -d
# docker exec 2sqli_db_1 /db-s/insert.sh
cd ..

# 3
cd 3.\ MySQL/
docker-compose up -d
mysql --host=127.0.0.1 -u root --password=chocolate < criation.sql
cd ..

# 4
cd 4.\ Torrent/
docker-compose up -d
cd ..

# 5
cd 5.\ FTP/
docker-compose up -d
cd ..

#6
cd 6.\ irc\ bot/
killall bot.py
python bot.py &
cd ..

# 8
cd 8.\ RCE/server/railsV/
docker-compose build
# docker-compose run --rm app bundle exec rake db:create RAILS_ENV=production
docker-compose up -d
cd ..
