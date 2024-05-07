# frozen_string_literal: true

# @type self: Rake::DSL

begin
  require "rubocop/rake_task"
rescue LoadError
  warn "'rubocop' gem not loaded: skipping tasks..."
  return
end

RuboCop::RakeTask.new

desc "Run RuboCop"
task check: :rubocop
