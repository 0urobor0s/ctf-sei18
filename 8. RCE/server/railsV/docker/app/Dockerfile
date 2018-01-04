# Base image:
FROM ruby:2.3.3
# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
# create application directory
RUN mkdir /myapp
# Set our working directory inside the image
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
EXPOSE 3000
CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]