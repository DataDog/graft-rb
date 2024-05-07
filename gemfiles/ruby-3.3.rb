source "https://rubygems.org"

gemspec path: ".."

gem "rake", "~> 13.1.0"

group :test do
  gem "minitest", "~> 5.22.3"
end

group :debug do
  gem "debug"
  gem "irb"
end

group :check do
  gem "rubocop", "~> 1.62.1", require: false
  gem "rubocop-minitest", "~> 0.33.0", require: false
  gem "rubocop-rake", "~> 0.6.0", require: false
  gem "standard", "~> 1.0", require: false
  gem "steep", "~> 1.6.0", require: false
end
