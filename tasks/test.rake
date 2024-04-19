# frozen_string_literal: true

# @type self: Rake::DSL

require 'minitest/test_task'

Minitest::TestTask.create(:test) do |t|
  t.warning = false
  t.test_globs = ['test/**/*_test.rb']
end
