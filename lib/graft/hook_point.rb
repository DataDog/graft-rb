# frozen_string_literal: true

module Graft
  class HookPointError < StandardError; end

  class HookModule < Module
    def initialize(key)
      super()

      @key = key
    end

    attr_reader :key

    def inspect
      "#<#{self.class.name}: #{@key.inspect}>"
    end
  end

  class HookPoint
    DEFAULT_STRATEGY = Module.respond_to?(:prepend) ? :prepend : :chain

    class << self
      # Parses a hook point string into its components.
      #
      # @param hook_point [String] The hook point string to parse.
      # @return [Array<Symbol, Symbol, Symbol>] An array containing the parsed components:
      #   - klass_name [Symbol]: The name of the class or module.
      #   - method_kind [Symbol]: The kind of method, either :klass_method or :instance_method.
      #   - method_name [Symbol]: The name of the method.
      # @raise [ArgumentError] If the hook point string is invalid or missing any components.
      def parse(hook_point)
        klass_name, separator, method_name = hook_point.split(/(\#|\.)/, 2)

        raise ArgumentError, hook_point if klass_name.nil? || separator.nil? || method_name.nil?
        raise ArgumentError, hook_point unless [".", "#"].include?(separator)

        method_kind = (separator == ".") ? :klass_method : :instance_method

        [klass_name.to_sym, method_kind, method_name.to_sym]
      end

      # Checks if a constant with the given name exists.
      #
      # @param name [String] the name of the constant to check
      # @return [Boolean] true if the constant exists, false otherwise
      def const_exist?(name)
        resolve_const(name) && true
      rescue NameError, ArgumentError
        false
      end

      # Resolves a constant by its name.
      #
      # @param name [String] The name of the constant to resolve.
      # @return [Object] The resolved constant.
      # @raise [ArgumentError] If the name is nil or empty, or if the constant is not found.
      def resolve_const(name)
        raise ArgumentError, "const not found: #{name}" if name.nil? || name.empty?

        name.to_s.split("::").inject(Object) { |a, e| a.const_get(e, false) }
      end

      # Resolves a module by name.
      #
      # @param name [String] The name of the module to resolve.
      # @return [Module] The resolved module.
      # @raise [ArgumentError] If the resolved constant is not a Module.
      def resolve_module(name)
        const = resolve_const(name)

        # TODO: Not covered by tests, cannot find a const that is not a Module
        raise ArgumentError, "not a Module: #{name}" unless const.is_a?(Module)

        const
      end

      # Returns the strategy module based on the given strategy symbol.
      #
      # @param strategy [Symbol] The strategy symbol (:prepend or :chain).
      # @return [Module] The strategy module corresponding to the given strategy symbol.
      # @raise [HookPointError] If the strategy symbol is unknown.
      def strategy_module(strategy)
        case strategy
        when :prepend then Prepend
        when :chain then Chain
        else
          raise HookPointError, "unknown strategy: #{strategy.inspect}"
        end
      end
    end

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

      if RUBY_VERSION < "3.0"
        def apply(obj, suffix, *args, &block)
          obj.send(:"#{method_name}_without_#{suffix}", *args, &block)
        end
      else
        def apply(obj, suffix, *args, **kwargs, &block)
          obj.send(:"#{method_name}_without_#{suffix}", *args, **kwargs, &block)
        end
      end
    end
  end
end
