# frozen_string_literal: true

if RUBY_VERSION < "3.0"
  require_relative "chain/applyable.ruby2"
else
  require_relative "chain/applyable.ruby3"
end

module Graft
  class HookPoint
    module Chain
      include Applyable

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
        hook_point = self # : HookPoint & Chain
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            # @type self: Module

            if hook_point.private_method?
              private
            elsif hook_point.protected_method?
              protected
            else
              public
            end

            # erase type: `block` is `^() -> untyped` but `define_method` expects
            # a `[self: Module]` constraint
            b = _ = block

            define_method(:"#{method_name}_with_#{suffix}", &b)
          end
        elsif instance_method?
          klass.class_eval do
            # @type self: Module

            if hook_point.private_method?
              private
            elsif hook_point.protected_method?
              protected
            else
              public
            end

            # erase type: `block` is `^() -> untyped` but `define_method` expects
            # a `[self: Module]` constraint
            b = _ = block

            define_method(:"#{method_name}_with_#{suffix}", &b)
          end
        else
          raise HookPointError, "unknown hook point kind"
        end
      end

      def remove(suffix)
        method_name = @method_name

        if klass_method?
          klass.singleton_class.instance_eval do
            # @type self: Module

            remove_method(:"#{method_name}_with_#{suffix}")
          end
        elsif instance_method?
          klass.class_eval do
            # @type self: Module

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
            # @type self: Module

            instance_method(:"#{method_name}").original_name == :"#{method_name}_with_#{suffix}"
          end
        elsif instance_method?
          klass.class_eval do
            # @type self: Module

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
            # @type self: Module

            alias_method :"#{method_name}_without_#{suffix}", :"#{method_name}"
            alias_method :"#{method_name}", :"#{method_name}_with_#{suffix}"
          end
        elsif instance_method?
          klass.class_eval do
            # @type self: Module

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
            # @type self: Module

            alias_method :"#{method_name}", :"#{method_name}_without_#{suffix}"
          end
        elsif instance_method?
          klass.class_eval do
            # @type self: Module

            alias_method :"#{method_name}", :"#{method_name}_without_#{suffix}"
          end
        end
      end
    end
  end
end
