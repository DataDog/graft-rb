# frozen_string_literal: true

module Graft
  class HookPointError < StandardError; end

  class HookModule < Module
    def initialize(key)
      super()

      @key = key
    end

    # @dynamic key
    attr_reader :key

    def inspect
      "#<#{self.class.name}: #{@key.inspect}>"
    end
  end

  class HookPoint
    DEFAULT_STRATEGY = Module.respond_to?(:prepend) ? :prepend : :chain

    class << self
      def parse(hook_point)
        klass_name, separator, method_name = hook_point.split(/(\#|\.)/, 2)

        raise ArgumentError, hook_point if klass_name.nil? || separator.nil? || method_name.nil?
        raise ArgumentError, hook_point unless [".", "#"].include?(separator)

        method_kind = (separator == ".") ? :klass_method : :instance_method

        [klass_name.to_sym, method_kind, method_name.to_sym]
      end

      def const_exist?(name)
        resolve_const(name) && true
      rescue NameError, ArgumentError
        false
      end

      def resolve_const(name)
        raise ArgumentError, "const not found: #{name}" if name.nil? || name.empty?

        name.to_s.split("::").inject(Object) { |a, e| a.const_get(e, false) }
      end

      def resolve_module(name)
        const = resolve_const(name)

        raise ArgumentError, "not a Module: #{name}" unless const.is_a?(Module)

        const
      end

      def strategy_module(strategy)
        # NOTE: when using `case` steep types the unreachable fallback as `bot`, workaround it with `if`
        return Prepend if strategy == :prepend
        return Chain if strategy == :chain

        raise HookPointError, "unknown strategy: #{strategy.inspect}"
      end
    end

    # @dynamic klass_name, method_kind, method_name
    attr_reader :klass_name, :method_kind, :method_name

    def initialize(hook_point, strategy = DEFAULT_STRATEGY)
      @klass_name, @method_kind, @method_name = HookPoint.parse(hook_point)
      @strategy = strategy

      extend HookPoint.strategy_module(strategy)
    end

    def to_s
      @to_s ||= "#{@klass_name}#{(@method_kind == :instance_method) ? "#" : "."}#{@method_name}"
    end

    def exist?
      return false unless HookPoint.const_exist?(@klass_name)

      if klass_method?
        (
          klass.singleton_class.public_instance_methods(false) +
          klass.singleton_class.protected_instance_methods(false) +
          klass.singleton_class.private_instance_methods(false)
        ).include?(@method_name)
      elsif instance_method?
        (
          klass.public_instance_methods(false) +
          klass.protected_instance_methods(false) +
          klass.private_instance_methods(false)
        ).include?(@method_name)
      else
        raise HookPointError, "#{self} unknown hook point kind"
      end
    end

    def klass
      HookPoint.resolve_module(@klass_name)
    end

    def klass_method?
      @method_kind == :klass_method
    end

    def instance_method?
      @method_kind == :instance_method
    end

    def private_method?
      if klass_method?
        klass.private_methods.include?(@method_name)
      elsif instance_method?
        klass.private_instance_methods.include?(@method_name)
      else
        raise HookPointError, "#{self} unknown hook point kind"
      end
    end

    def protected_method?
      if klass_method?
        klass.protected_methods.include?(@method_name)
      elsif instance_method?
        klass.protected_instance_methods.include?(@method_name)
      else
        raise HookPointError, "#{self} unknown hook point kind"
      end
    end

    def installed?(key) # rubocop:disable Lint/UselessMethodDefinition
      super
    end

    def install(key, &block)
      return unless exist?

      return if installed?(key)

      super
    end

    def uninstall(key)
      return unless exist?

      return unless installed?(key)

      super
    end

    def enable(key) # rubocop:disable Lint/UselessMethodDefinition
      super
    end

    def disable(key) # rubocop:disable Lint/UselessMethodDefinition
      super
    end

    def disabled?(key) # rubocop:disable Lint/UselessMethodDefinition
      super
    end

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
        hook_point = self
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

    module Chain
      def installed?(key)
        defined(key)
      end

      def install(key, &block)
        define(key, &block)
        chain(key)
      end

      def uninstall(key)
        disable(key)
        remove(key)
      end

      def enable(key)
        chain(key)
      end

      def disable(key)
        unchain(key)
      end

      def disabled?(key)
        !chained?(key)
      end

      private

      def defined(suffix)
        if klass_method?
          (
            klass.methods +
            klass.protected_methods +
            klass.private_methods
          ).include?(:"#{method_name}_with_#{suffix}")
        elsif instance_method?
          (
            klass.instance_methods +
            klass.protected_instance_methods +
            klass.private_instance_methods
          ).include?(:"#{method_name}_with_#{suffix}")
        else
          raise HookPointError, "#{self} unknown hook point kind"
        end
      end

      def define(suffix, &block)
        hook_point = self
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            if hook_point.private_method?
              private
            elsif hook_point.protected_method?
              protected
            else
              public
            end

            define_method(:"#{method_name}_with_#{suffix}", &block)
          end
        elsif instance_method?
          klass.class_eval do
            if hook_point.private_method?
              private
            elsif hook_point.protected_method?
              protected
            else
              public
            end

            define_method(:"#{method_name}_with_#{suffix}", &block)
          end
        else
          raise HookPointError, "unknown hook point kind"
        end
      end

      def remove(suffix)
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            remove_method(:"#{method_name}_with_#{suffix}")
          end
        elsif instance_method?
          klass.class_eval do
            remove_method(:"#{method_name}_with_#{suffix}")
          end
        else
          raise HookPointError, "unknown hook point kind"
        end
      end

      def chained?(suffix)
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            instance_method(:"#{method_name}").original_name == :"#{method_name}_with_#{suffix}"
          end
        elsif instance_method?
          klass.class_eval do
            instance_method(:"#{method_name}").original_name == :"#{method_name}_with_#{suffix}"
          end
        else
          raise HookPointError, "unknown hook point kind"
        end
      end

      def chain(suffix)
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            alias_method :"#{method_name}_without_#{suffix}", :"#{method_name}"
            alias_method :"#{method_name}", :"#{method_name}_with_#{suffix}"
          end
        elsif instance_method?
          klass.class_eval do
            alias_method :"#{method_name}_without_#{suffix}", :"#{method_name}"
            alias_method :"#{method_name}", :"#{method_name}_with_#{suffix}"
          end
        else
          raise HookPointError, "unknown hook point kind"
        end
      end

      def unchain(suffix)
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            alias_method :"#{method_name}", :"#{method_name}_without_#{suffix}"
          end
        elsif instance_method?
          klass.class_eval do
            alias_method :"#{method_name}", :"#{method_name}_without_#{suffix}"
          end
        end
      end

      # @dynamic apply
      # Using `define_method` instead of `def` as the latter trips up static type checking
      if RUBY_VERSION < "3.0"
        define_method :apply do |obj, suffix, *args, &block|
          obj.send(:"#{method_name}_without_#{suffix}", *args, &block)
        end
      else
        define_method :apply do |obj, suffix, *args, **kwargs, &block|
          obj.send(:"#{method_name}_without_#{suffix}", *args, **kwargs, &block)
        end
      end
    end
  end
end
