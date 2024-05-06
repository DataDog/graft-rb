# frozen_string_literal: true

source "https://rubygems.org"

gem "rake", "~> 13.1.0"

gemspec

group :test do
  gem "minitest", "~> 5.20.0"
end

group :check do
  gem "rubocop", "~> 1.62.1", require: false
  gem "rubocop-minitest", "~> 0.33.0", require: false
  gem "rubocop-rake", "~> 0.6.0", require: false
  gem "standard", "~> 1.0", require: false
  gem "steep", "~> 1.6.0", require: false
end

group :debug do
  gem "debug"
  gem "irb"
end
