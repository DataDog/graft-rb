# frozen_string_literal: true

module Graft
  class Callback
    # @dynamic name
    attr_reader :name

    # NOTE: opts is not used in the current implementation
    def initialize(name = nil, opts = {}, &block)
      @name = name
      @opts = opts
      @block = block
      @enabled = true
    end

    # @dynamic call
    # Using `define_method` instead of `def` as the latter trips up static type checking
    if RUBY_VERSION < "3.0"
      define_method :call do |*args, &block|
        return unless enabled?

        @block.call(*args, &block)
      end
    else
      define_method :call do |*args, **kwargs, &block|
        return unless enabled?

        @block.call(*args, **kwargs, &block)
      end
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
