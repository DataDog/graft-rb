# frozen_string_literal: true

module Graft
  class Hook
    module Wrapper
      def wrapper(hook)
        proc do |*args, &block|
          env = {
            self: self,
            args: args,
            block: block
          }
          supa = proc { |*args, &block| super(*args, &block) }
          mid = proc { |_, env| {return: supa.call(*env[:args], &env[:block])} }
          stack = hook.stack.dup
          stack << mid

          stack.call(env)
        end
      end
    end
  end
end
