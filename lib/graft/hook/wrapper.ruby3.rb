# frozen_string_literal: true

module Graft
  class Hook
    module Wrapper
      def wrapper(hook)
        point = hook.point

        proc do |*args, **kwargs, &block|
          env = {
            receiver: self,
            method: point.method_name,
            kind: point.method_kind,
            strategy: point.instance_variable_get(:@strategy),
            args: args,
            kwargs: kwargs,
            block: block
          }

          supa = case env[:strategy]
          when :prepend
            proc { |*args, **kwargs, &block| super(*args, **kwargs, &block) }
          when :chain
            proc { |*args, **kwargs, &block| hook.point.apply(env[:receiver], Hook::KEY, *args, **kwargs, &block) }
          else
            raise HookPointError, "unknown strategy: #{env[:strategy]}"
          end
          mid = Callback.new { |_, env| {return: supa.call(*env[:args], **env[:kwargs], &env[:block])} }
          stack = hook.stack.dup
          stack << mid

          stack.call(env)[:return]
        end
      end
    end
  end
end
