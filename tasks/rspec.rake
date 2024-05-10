# frozen_string_literal: true

# @type self: Rake::DSL

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t, args|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = args.to_a.join(" ")
end
