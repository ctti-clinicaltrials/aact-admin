FROM ruby:2.6.6

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client 

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install bundler:1.17.3
RUN bundle install --without development test

# Create non-root user and set ownership and permissions as required
RUN adduser --disabled-password aact && chown -R aact /app

COPY . /app

RUN RAILS_ENV=production bundle exec rake assets:precompile

# Switch to the user
USER aact

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]