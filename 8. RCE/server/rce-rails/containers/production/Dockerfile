FROM ruby:2.3.3

ENV RAILS_ROOT=/usr/app/rce-rails
ENV RAILS_ENV=production

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir -p $RAILS_ROOT/tmp/pids
WORKDIR $RAILS_ROOT

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle check || bundle install --without development test -j4

COPY config/puma.rb config/puma.rb

COPY . .

RUN mkdir -p /etc/nginx/conf.d/
COPY ./containers/production/nginx.conf /etc/nginx/conf.d/default.conf

RUN DB_ADAPTER=nulldb bundle exec rails assets:precompile RAILS_ENV=production

EXPOSE 3000
