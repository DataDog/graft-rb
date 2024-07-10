# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"

  # ignore per version dynamic definitions for old rubies
  ignore "lib/**/*.ruby2.rb"

  configure_code_diagnostics do |hash|
    hash[D::Ruby::UnknownInstanceVariable] = :error
    hash[D::Ruby::MethodDefinitionMissing] = :error
  end
end

# target :gem do
#   check '*.gemspec'
#   check 'Gemfile'
# end
#
# target :test do
#   signature 'sig'
#
#   library 'minitest'
#
#   check 'test'
# end
#
# target :tasks do
#   library 'minitest'
#   library 'rake'
#   library 'csv'
#
#   signature 'tasks/sig'
#
#   check 'tasks/**/*.rake'
#   check 'Rakefile'
# end
