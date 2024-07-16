# frozen_string_literal: true

require "minitest/reporters"

# Minitest::Reporters::DefaultReporter misreports `skip` location
# as being in Minitest source instead of actual `skip` location
# See: https://github.com/minitest-reporters/minitest-reporters/issues/356
module FixSkipLocation
  def location(exception)
    exception.location
  end
end
Minitest::Reporters::DefaultReporter.prepend FixSkipLocation

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
