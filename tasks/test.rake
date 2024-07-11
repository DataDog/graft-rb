# frozen_string_literal: true

# @type self: Rake::DSL

if Gem.loaded_specs["minitest"]
  begin
    require "minitest/test_task"
  rescue LoadError
    # Backport "minitest/test_task" for minitest 5.15.0
    require_relative "../vendor/minitest/test_task"
  end
else
  warn "'minitest' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

Minitest::TestTask.create(:"minitest:test") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_globs = ["test/**/test_*.rb"]
end

Minitest::TestTask.create(:"minitest:spec") do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_globs = ["spec/**/*_spec.rb"]
end

desc "Run tests"
task test: :"minitest:test"

desc "Run specs"
task spec: :"minitest:spec"
