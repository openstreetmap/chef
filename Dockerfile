# Basic Dockerfile to run cookstyle linting
# run: docker build -t chef-test .
FROM ruby:2.7-alpine as build

# Add Gem build requirements
RUN apk add --no-cache build-base

# Create app directory
WORKDIR /app

# Add Gemfile and Gemfile.lock
ADD Gemfile* ./

# Install Gems
RUN gem install bundler \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle config --global jobs $(nproc) \
    && bundle install

# Add repo
ADD . .

# Run linting
RUN bundle exec cookstyle -f fuubar
