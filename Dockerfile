FROM ruby:2.7-slim

RUN bundle config --global frozen 1
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

EXPOSE 8000
CMD ["/usr/local/bin/bundle", "exec", "rackup", "--host=0.0.0.0", "--port=8000"]
