# Docker image used for running repo tooling (e.g. Cookstyle) in local containers.
FROM ruby:3.3-trixie AS build

# Add Gem build requirements
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            build-essential \
            pkg-config \
            libxml2-dev \
            libxslt1-dev \
            zlib1g-dev \
        && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /usr/src/app

# Add Gemfile and Gemfile.lock
ADD Gemfile* ./

# Install Gems
RUN gem install bundler -v 2.6.9 \
    && bundle config set build.nokogiri --use-system-libraries \
    && bundle config set --global jobs $(nproc) \
    && bundle install
