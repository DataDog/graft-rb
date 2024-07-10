# frozen_string_literal: true

module Graft
  class Callback
    module Callable
      def call(*args, **kwargs, &block)
        return unless enabled?

        @block.call(*args, **kwargs, &block)
      end
    end
  end
end
