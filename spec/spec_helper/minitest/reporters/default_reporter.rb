# frozen_string_literal: true

# Minitest::Reporters::DefaultReporter misreports `skip` location
# as being in Minitest source instead of actual `skip` location
# See: https://github.com/minitest-reporters/minitest-reporters/issues/356
module Minitest::Reporters::DefaultReporter::FixSkipLocation
  def location(exception)
    exception.location
  end
end

Minitest::Reporters::DefaultReporter.prepend Minitest::Reporters::DefaultReporter::FixSkipLocation
