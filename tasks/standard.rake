# frozen_string_literal: true

# @type self: Rake::DSL

begin
  require "standard/rake"

  desc "Run StandardRB"
  task check: :standard
rescue LoadError
end
