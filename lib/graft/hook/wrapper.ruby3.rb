# frozen_string_literal: true

module Graft
  class Hook
    module Wrapper
      def wrapper(hook)
        proc do |*args, **kwargs, &block|
          env = {
            receiver: self,
            method: hook.point.method_name,
            kind: hook.point.method_kind,
            strategy: hook.point.instance_variable_get(:@strategy),
            args: args,
            kwargs: kwargs,
            block: block
          }

          supa = proc { |*args, **kwargs, &block| super(*args, **kwargs, &block) }
          mid = proc { |_, env| {return: supa.call(*env[:args], **env[:kwargs], &env[:block])} }
          stack = hook.stack.dup
          stack << mid

          stack.call(env)[:return]
        end
      end
    end
  end
end
