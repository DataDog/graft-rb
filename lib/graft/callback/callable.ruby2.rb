# frozen_string_literal: true

module Graft
  class Callback
    module Callable
      def call(*args, &block)
        return unless enabled?

        @block.call(*args, &block)
      end
    end
  end
end
