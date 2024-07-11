# frozen_string_literal: true

# @type self: Rake::DSL

begin
  require "rspec/core/rake_task"
rescue LoadError
  warn "'rspec' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

RSpec::Core::RakeTask.new(:spec) do |t, args|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = args.to_a.join(" ")
end
