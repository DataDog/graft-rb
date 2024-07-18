# frozen_string_literal: true

# @type self: Rake::DSL

if Gem.loaded_specs["bundler"]
  require "bundler/gem_tasks"
else
  warn "'bundler' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end
