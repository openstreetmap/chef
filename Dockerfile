FROM ruby:2.6

WORKDIR /app

RUN apt-get update \
	&& apt-get install -y --no-install-recommends libssl-dev

ADD Gemfile* /app/
RUN gem install bundler --no-document \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle install --jobs $(nproc) --retry 5

ADD . /app/

RUN bundle exec cookstyle -f fuubar
