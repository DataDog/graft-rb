FROM ghcr.io/datadog/images-rb/engines/ruby:2.5

# Make apt non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Set language
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# Install RubyGems
RUN mkdir -p "$GEM_HOME" && chmod -R 777 "$GEM_HOME"

# rubygems drops support for ruby 2.5 in 3.4.0
# https://github.com/rubygems/rubygems/blob/master/CHANGELOG.md#340--2022-12-24
#
# 3.3.26 is the last version that supports ruby 2.5
# and installs bundler 2.3.26 as a default gem
RUN gem update --system 3.3.26

ENV BUNDLE_SILENCE_ROOT_WARNING 1

RUN mkdir /app
WORKDIR /app

CMD ["/bin/sh"]
