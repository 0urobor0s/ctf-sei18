# Blog post for this: https://medium.com/@sabman/running-rails-5-0-1-postgis-using-docker-compose-2-a0ce5e5fbaba#.j6scfvmw6

APP_NAME=dockerized-rails
rails new $APP_NAME -d postgresql
cd $APP_NAME
mkdir -p containers/development
RAILS_ENV=development

# 1. create a Dockerfile for development
cat > ./containers/development/Dockerfile <<EOF
FROM ruby:2.4.2-slim
ENV RAILS_ROOT=/usr/app/${APP_NAME}
ENV RAILS_ENV=${RAILS_ENV}

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client libproj-dev nodejs less

# Dependencies for rgeo
RUN apt-get --no-install-recommends -y install libgeos-dev libproj-dev

# Add libgeos symlinks for rgeo gem to be able to find it
RUN ln -sf /usr/lib/libgeos-3.4.2.so /usr/lib/libgeos.so && ln -sf /usr/lib/libgeos-3.4.2.so /usr/lib/libgeos.so.1

RUN mkdir -p \$RAILS_ROOT/tmp/pids
WORKDIR \$RAILS_ROOT
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN  bundle install
COPY . .
EXPOSE 3000
EOF

# 2. create a docker-compose.yml file
# we need wait-for-it.sh to make sure that the rails app waits for the db to be up before trying to connect. Otherwise the container can crash.
mkdir containers/scripts
wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -P containers/scripts
chmod +x containers/scripts/wait-for-it.sh
cat > containers/development/docker-compose.yml <<EOF
version: '2'
services:
  db:
    image: mdillon/postgis:9.6
    ports:
      - 5432:5432
    env_file:
      - containers/development/.env
  app:
    tty: true
    stdin_open: true
    build:
      context: .
      dockerfile: containers/development/Dockerfile
    env_file:
      - containers/development/.env
    command: containers/scripts/wait-for-it.sh db:5432 -- containers/development/entrypoint
    depends_on:
      - db
    volumes:
      - .:/usr/app/${APP_NAME}
    ports:
      - 3000:3000
EOF

# lets add an entrypoint script
cat > containers/development/entrypoint <<EOF
#!/bin/bash
set -e
bundle check || bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec puma -C config/puma.rb
exec "$@"
EOF

# set executable permissions
chmod +x containers/development/entrypoint

# 3. create a .env file
cat > containers/development/.env <<EOF
PGPASSWORD=mypass
RAILS_ENV=${RAILS_ENV}
RAILS_ROOT=/usr/app/${APP_NAME}
EOF

# 4. add a database.yml
cat > config/database.yml <<EOF
default: &default
  adapter: postgis
  pool: 5
  timeout: 5000
  username: postgres
  password: <%= ENV['PGPASSWORD'] %>
  host: db
test:
  <<: *default
  database: ${APP_NAME}_test
development:
  <<: *default
  database: ${APP_NAME}_development
EOF

# 5. add postgis adapter and add pg
echo  "gem 'activerecord-postgis-adapter'" >> Gemfile

# symlink the docker-compose.yml in the rails root directory
ln -s containers/development/docker-compose.yml
docker-compose build
docker-compose up
open http://`docker-machine ip`:3000