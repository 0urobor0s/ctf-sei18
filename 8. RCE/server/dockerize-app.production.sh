APP_NAME=rce-rails
RAILS_ROOT=/usr/app/${APP_NAME}
RAILS_ENV=production

cd $APP_NAME

# Before we start we'll make sure that we have a scaffolded app just to make sure we can test everything is working.

#docker-compose up
#docker-compose run app bundle exec rails generate scaffold post title body:text published:boolean RAILS_ENV=development
#docker-compose run app bundle exec rake db:migrate RAILS_ENV=development

# We can also make sure the development test works:

#docker-compose run app bundle exec rake db:setup RAILS_ENV=test
#docker-compose run app bundle exec rake test RAILS_ENV=test

mkdir -p containers/$RAILS_ENV

# Add nulldb gem to allow creating assets without a db connection
# read: http://blog.zeit.io/use-a-fake-db-adapter-to-play-nice-with-rails-assets-precompilation/"

echo "gem 'activerecord-nulldb-adapter'" >> Gemfile

# create Dockerfile
cat > containers/$RAILS_ENV/Dockerfile <<EOF
FROM ruby:2.3.3

ENV RAILS_ROOT=/usr/app/${APP_NAME}
ENV RAILS_ENV=production

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir -p \$RAILS_ROOT/tmp/pids
WORKDIR \$RAILS_ROOT

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle check || bundle install --without development test -j4

COPY config/puma.rb config/puma.rb

COPY . .

RUN mkdir -p /etc/nginx/conf.d/
COPY ./containers/${RAILS_ENV}/nginx.conf /etc/nginx/conf.d/default.conf

RUN DB_ADAPTER=nulldb bundle exec rails assets:precompile RAILS_ENV=production

EXPOSE 3000
EOF

# create a compose file

cat > containers/${RAILS_ENV}/docker-compose.yml <<EOF
version: '2'

services:
  nginx:
    image: nginx:1.11.9
    volumes_from:
      - app
    depends_on:
      - app
    ports:
      - 8080:80
  db:
    image: postgres:9.6
    ports:
      - 5432:5432
    env_file:
      - containers/${RAILS_ENV}/.env
    volumes:
      - data:/var/lib/postgresql/db-data
  app:
    build:
      context: .
      dockerfile: containers/${RAILS_ENV}/Dockerfile
    env_file:
      - containers/${RAILS_ENV}/.env
    command: containers/scripts/wait-for-it.sh db:5432 -- containers/${RAILS_ENV}/entrypoint
    volumes:
      - assets:/usr/app/${APP_NAME}/public/assets
      - nginx_config:/etc/nginx/conf.d
    depends_on:
      - db
    ports:
      - 3000:3000

volumes:
  assets:
    external: false
  data:
    external: false
  nginx_config:
    external: false
EOF


# add app specific nginx.config
SERVER_NAME="${APP_NAME}.prod"
cat > containers/production/nginx.conf <<EOF
upstream rails_app {
  server app:3000;
}

server {
  listen 80;
  keepalive_timeout 10;

  server_name ${SERVER_NAME};
  root /usr/app/${APP_NAME}/public;

  location / {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;

    # If the file exists as a static file serve it directly without
    # running all the other rewrite tests on it
    if (-f \$request_filename) {
      break;
    }
    if (-f \$request_filename/index.html) {
      rewrite (.*) \$1/index.html break;
    }
    if (-f \$request_filename.html) {
      rewrite (.*) \$1.html break;
    }

    if (!-f \$request_filename) {
      proxy_pass http://rails_app;
      break;
    }
  }
  location ~* \.(ico|css|gif|jpe?g|png|js)(\?[0-9]+)?\$ {
     expires max;
     break;
  }

  # Error pages
  # error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /usr/app/${APP_NAME}/public;
  }
}
EOF

PGPASSWORD=`openssl rand -base64 8`
cat > containers/${RAILS_ENV}/.env <<EOF
PGPASSWORD=${PGPASSWORD}
POSTGRES_PASSWORD=${PGPASSWORD}
RAILS_ENV=production
RACK_ENV=production
RAILS_ROOT=/usr/app/${APP_NAME}
SECRET_KEY_BASE=`docker-compose run app bundle exec rake secret`
EOF

cat >> config/database.yml <<EOF
${RAILS_ENV}:
  <<: *default
  database: ${APP_NAME}_${RAILS_ENV}
EOF


cat > containers/${RAILS_ENV}/entrypoint <<EOF
#!/bin/bash
set -e

if [[ -a /tmp/puma.pid ]]; then
  rm /tmp/puma.pid
fi

bundle exec rake db:create
bundle exec rake db:migrate

if [[ \$RAILS_ENV == "production" ]]; then
  rake assets:precompile
  mkdir -p /etc/nginx/conf.d/
  cp containers/${RAILS_ENV}/nginx.conf /etc/nginx/conf.d/default.conf
fi

rails server -b 0.0.0.0 -P /tmp/puma.pid

exec "\$@"
EOF

chmod +x containers/${RAILS_ENV}/entrypoint

rm docker-compose.yml

ln -s containers/${RAILS_ENV}/docker-compose.yml
