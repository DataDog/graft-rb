# frozen_string_literal: true

require "minitest/reporters"

require_relative "reporters/default_reporter"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
