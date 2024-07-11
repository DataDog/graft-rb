# frozen_string_literal: true

# @type self: Rake::DSL

if Gem.loaded_specs["rubocop"]
  require "rubocop/rake_task"
else
  warn "'rubocop' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

RuboCop::RakeTask.new

desc "Run RuboCop"
task check: :rubocop
