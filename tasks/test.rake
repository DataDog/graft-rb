# frozen_string_literal: true

# @type self: Rake::DSL

begin
  require "minitest/test_task"
rescue LoadError
  # Backport "minitest/test_task" for minitest 5.15.0
  require_relative "../vendor/minitest/test_task"
end

Minitest::TestTask.create(:test) do |t|
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end
