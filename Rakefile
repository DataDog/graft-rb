# frozen_string_literal: true

# @type self: Rake::TaskLib

# load rake tasks from tasks directory
Dir.glob(File.join(__dir__ || Dir.pwd, 'tasks', '*.rake')) { |f| import f }

task :default => [:test, :check]

desc 'Run checks'
task :check => [:rubocop, :'steep:check']
