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
          supa = case env[:strategy]
          when :prepend
            proc { |*args, &block| super(*args, &block) }
          when :chain
            proc { |*args, &block| hook.point.apply(env[:receiver], Hook::KEY, *args, **kwargs, &block) }
          else
            raise HookPointError, "unknown strategy: #{env[:strategy]}"
          end
          mid = proc { |_, env| {return: supa.call(*env[:args], &env[:block])} }
          stack = hook.stack.dup
          stack << mid

          stack.call(env)
        end
      end
    end
  end
end
