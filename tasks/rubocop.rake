# frozen_string_literal: true

# @type self: Rake::DSL

begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new

  desc "Run RuboCop"
  task check: :rubocop
rescue LoadError
end
