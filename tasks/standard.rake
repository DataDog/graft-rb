# frozen_string_literal: true

# @type self: Rake::DSL

if Gem.loaded_specs["standard"]
  require "standard/rake"
else
  warn "'standard' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

desc "Run StandardRB"
task check: :standard
