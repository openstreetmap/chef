FROM ruby:2.4

WORKDIR /app

RUN apt-get update \
	&& apt-get install -y --no-install-recommends libssl1.0-dev

ADD Gemfile* /app/
RUN gem install bundler && bundle config build.nokogiri --use-system-libraries && bundle install --jobs 4 --retry 5

ADD . /app/

RUN bundle exec rubocop -f fuubar
RUN bundle exec foodcritic -f any cookbooks
