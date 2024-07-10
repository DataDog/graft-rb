# frozen_string_literal: true

module Graft
  class HookPoint
    module Prepend
      def installed?(key)
        prepended?(key) && overridden?(key)
      end

      def install(key, &block)
        prepend(key)
        override(key, &block)
      end

      def uninstall(key)
        unoverride(key) if overridden?(key)
      end

      def enable(key)
        raise HookPointError, "enable(#{key.inspect}) with prepend strategy"
      end

      def disable(key)
        unoverride(key)
      end

      def disabled?(key)
        !overridden?(key)
      end

      private

      def hook_module(key)
        target = klass_method? ? klass.singleton_class : klass

        mod = target.ancestors.each do |e|
          break if e == target
          break(e) if e.instance_of?(HookModule) && e.key == key
        end

        raise HookPointError, "Inconsistency detected: #{target} missing from its own ancestors" if mod.is_a?(Array)

        [target, mod]
      end

      def prepend(key)
        target, mod = hook_module(key)

        mod ||= HookModule.new(key)

        target.prepend(mod)
      end

      def prepended?(key)
        _, mod = hook_module(key)

        mod != nil
      end

      def overridden?(key)
        _, mod = hook_module(key)

        (
          mod.instance_methods(false) +
          mod.protected_instance_methods(false) +
          mod.private_instance_methods(false)
        ).include?(method_name)
      end

      def override(key, &block)
        hook_point = self # : HookPoint & HookPoint::Prepend
        method_name = @method_name

        _, mod = hook_module(key)

        mod.instance_eval do
          if hook_point.private_method?
            private
          elsif hook_point.protected_method?
            protected
          else
            public
          end

          define_method(:"#{method_name}", &block)
        end
      end

      def unoverride(key)
        method_name = @method_name

        _, mod = hook_module(key)

        mod.instance_eval { remove_method(method_name) }
      end
    end
  end
end
