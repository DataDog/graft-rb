# frozen_string_literal: true

# @type self: Rake::DSL

if Gem.loaded_specs["rbs"]
  # noop
else
  warn "'rbs' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

namespace :rbs do
  namespace :collection do
    desc "Install RBS signatures"
    task :install do
      sh "rbs collection install"
    end

    desc "Update RBS signatures"
    task :update do
      sh "rbs collection update"
    end

    desc "Clean RBS signatures"
    task :clean do
      sh "rbs collection clean"
    end
  end
end
