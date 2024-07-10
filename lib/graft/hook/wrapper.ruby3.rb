# frozen_string_literal: true

module Graft
  class Hook
    module Wrapper
      def wrapper(hook)
        point = hook.point

        p = proc do |*args, **kwargs, &block|
          # @type self: Object

          env = {
            receiver: self,
            method: point.method_name,
            kind: point.method_kind,
            strategy: point.instance_variable_get(:@strategy),
            args: args,
            kwargs: kwargs,
            block: block
          }

          supa = case point
          when HookPoint::Prepend
            proc { |*args, **kwargs, &block| super(*args, **kwargs, &block) }
          when HookPoint::Chain
            proc { |*args, **kwargs, &block| point.apply(env[:receiver], Hook::KEY, *args, **kwargs, &block) }
          else
            raise HookPointError, "unknown strategy: #{env[:strategy]}"
          end

          # TODO: `case` eats `supa`'s type
          # @type var supa: ^(*untyped, **untyped) -> untyped
          mid = Callback.new { |_, env| {return: supa.call(*env[:args], **env[:kwargs], &env[:block])} }
          stack = hook.stack.dup
          stack << mid

          stack.call(env)[:return]
        end

        # erase type: `proc` returns a `::Proc` type, not `^() -> untyped`
        _ = p
      end
    end
  end
end
