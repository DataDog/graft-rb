# frozen_string_literal: true

module Graft
  class Callback
    attr_reader :name

    # NOTE: opts is not used in the current implementation
    def initialize(name = nil, opts = {}, &block)
      @name = name
      @opts = opts
      @block = block
      @enabled = true
    end

    if RUBY_VERSION < "3.0"
      def call(*args, &block)
        return unless enabled?

        @block.call(*args, &block)
      end
    else
      def call(*args, **kwargs, &block)
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
