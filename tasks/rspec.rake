# frozen_string_literal: true

# @type self: Rake::DSL

if Gem.loaded_specs["rspec"]
  require "rspec/core/rake_task"
else
  warn "'rspec' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

RSpec::Core::RakeTask.new(:"rspec:spec") do |t, args|
  t.libs << "spec"
  t.libs << "lib"
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = args.to_a.join(" ")
end

desc "Run specs"
task spec: :"minitest:spec"
