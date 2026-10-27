# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.4

# ── Base ──────────────────────────────────────────────────────────────────────
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH="/usr/local/bundle" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# ── Build ─────────────────────────────────────────────────────────────────────
FROM base AS build

ARG RAILS_ENV=production
ENV RAILS_ENV=$RAILS_ENV

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential git libpq-dev libvips libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./

RUN if [ "$RAILS_ENV" = "production" ]; then export BUNDLE_WITHOUT=development:test; fi && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

COPY . .

RUN if [ "$RAILS_ENV" = "production" ]; then export BUNDLE_WITHOUT=development:test; fi && \
    bundle exec bootsnap precompile -j 1 app/ lib/

RUN if [ "$RAILS_ENV" = "production" ]; then \
      export BUNDLE_WITHOUT=development:test && \
      SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile; \
    fi

# ── Development ───────────────────────────────────────────────────────────────
FROM base AS development

ENV RAILS_ENV=development \
    BUNDLE_PATH="/usr/local/bundle"

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

RUN mkdir -p tmp/pids tmp/sockets log storage && \
    chown -R rails:rails /rails

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

# ── Production ────────────────────────────────────────────────────────────────
FROM base AS production

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT="development:test"

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
