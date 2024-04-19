# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature 'sig'

  check 'lib'

  configure_code_diagnostics do |hash|
    hash[D::Ruby::UnknownInstanceVariable] = :warning
    hash[D::Ruby::NoMethod] = :warning
    hash[D::Ruby::MethodDefinitionMissing] = :warning
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
