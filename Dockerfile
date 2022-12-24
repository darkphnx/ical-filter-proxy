FROM ruby:2.7-slim

RUN useradd --user-group --system --create-home --no-log-init app
USER app
WORKDIR /app

RUN bundle config --global frozen 1
COPY --chown=app Gemfile Gemfile.lock ./
RUN bundle install

COPY --chown=app . .

EXPOSE 8000
CMD ["/usr/local/bin/bundle", "exec", "rackup", "--host=0.0.0.0", "--port=8000"]
