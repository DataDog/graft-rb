# frozen_string_literal: true

if RUBY_VERSION < "3.0"
  require_relative "callback/callable.ruby2"
else
  require_relative "callback/callable.ruby3"
end

module Graft
  class Callback
    include Callable

    # @dynamic name
    attr_reader :name

    # NOTE: opts is not used in the current implementation
    def initialize(name = nil, opts = {}, &block)
      @name = name
      @opts = opts
      @block = block
      @enabled = true
    end

    def disable
      @enabled = false
    end

    def enable
      @enabled = true
    end

    def enabled?
      @enabled
    end
  end
end
