FROM ghcr.io/datadog/images-rb/engines/ruby:3.1

# Make apt non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Set language
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# Install RubyGems
RUN mkdir -p "$GEM_HOME" && chmod -R 777 "$GEM_HOME"

# 3.5.10 installs bundler 2.5.10 as a default gem
RUN gem update --system 3.5.10

ENV BUNDLE_SILENCE_ROOT_WARNING 1

RUN mkdir /app
WORKDIR /app

CMD ["/bin/sh"]
