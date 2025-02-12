if %w[y yes true 1].include? ENV["COVERAGE"]
  require "simplecov"
  require "simplecov_json_formatter"
  require_relative "simplecov/formatters/markdown_formatter"

  SimpleCov.configure do
    add_filter %r{(?:spec|test|bin)}

    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter,
      SimpleCov::Formatter::MarkdownFormatter
    ]

    # Ruby 2.5+
    if RUBY_VERSION >= "2.5."
      enable_coverage :branch
      # primary_coverage :branch
    end

    # Ruby 3.2+
    enable_coverage_for_eval if RUBY_VERSION >= "3.2."
  end

  SimpleCov.start
end
