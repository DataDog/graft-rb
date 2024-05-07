# frozen_string_literal: true

# @type self: Rake::DSL

begin
  require "standard/rake"
rescue LoadError
  warn "'standard' gem not loaded: skipping tasks..."
  return
end

desc "Run StandardRB"
task check: :standard
