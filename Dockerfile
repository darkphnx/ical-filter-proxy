FROM ruby:3.4-alpine AS base
RUN apk add --update tzdata

FROM base AS dependencies
RUN apk add --update build-base
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle install --jobs=3 --retry=3

FROM base
RUN adduser -D app
USER app
WORKDIR /app
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --chown=app . ./

EXPOSE 9292
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
