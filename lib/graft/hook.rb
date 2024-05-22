# frozen_string_literal: true

require_relative "stack"
require_relative "callback"
require_relative "hook_point"

module Graft
  class Hook
    DEFAULT_STRATEGY = HookPoint::DEFAULT_STRATEGY

    @hooks = {}

    # NOTE: API Design - Should we push to ::Graft module?
    # NOTE: API Design - Should we support a HookPoint object being injected?
    #
    # If the key exists:
    #  - add a callback to the hook.
    # If the key does not exist:
    #  - add a new hook to the @hooks hash
    #  - add a callback to the hook.
    def self.add(hook_point, strategy = DEFAULT_STRATEGY, &block)
      self[hook_point, strategy].add(&block)
    end

    # NOTE: API Design - Should we push to ::Graft module?
    # NOTE: API Design - Should we support a HookPoint object being injected?
    # NOTE: Implementation Design - Hash key implementation
    #
    # If the key exists:
    #  - return the existing hook.
    # If the key does not exist:
    #  - create a new hook and add it to the @hooks hash.
    #  - return the existing hook.
    def self.[](hook_point, strategy = DEFAULT_STRATEGY)
      @hooks[hook_point] ||= new(hook_point, nil, strategy)
    end

    # NOTE: API Design - Should we push to ::Graft module?
    # NOTE: Is this used?
    def self.ignore
      Thread.current[:hook_entered] = true
      yield
    ensure
      Thread.current[:hook_entered] = false
    end

    attr_reader :point, :stack

    # NOTE: Push logic upward ClassMethods
    def initialize(hook_point, dependency_test = nil, strategy = DEFAULT_STRATEGY)
      @disabled = false
      @point = hook_point.is_a?(HookPoint) ? hook_point : HookPoint.new(hook_point, strategy)
      @dependency_test = dependency_test || proc { point.exist? }
      @stack = Stack.new
    end

    def dependency?
      return true if @dependency_test.nil?

      @dependency_test.call
    end

    def add(&block)
      tap { instance_eval(&block) }
    end

    def callback_name(tag = nil)
      point.to_s << (tag ? ":#{tag}" : "")
    end

    def append(tag = nil, opts = {}, &block)
      @stack << Callback.new(callback_name(tag), opts, &block)
    end

    def unshift(tag = nil, opts = {}, &block)
      @stack.unshift Callback.new(callback_name(tag), opts, &block)
    end

    def before(tag = nil, opts = {}, &block)
      # TODO
    end

    def after(tag = nil, opts = {}, &block)
      # TODO
    end

    def depends_on(&block)
      @dependency_test = block
    end

    def enable
      @disabled = false
    end

    def disable
      @disabled = true
    end

    def disabled?
      @disabled
    end

    def enabled?
      !disabled?
    end

    def install
      return unless point.exist?

      point.install("hook", &Hook.wrapper(self))
    end

    def uninstall
      return unless point.exist?

      point.uninstall("hook")
    end

    class << self
      if RUBY_VERSION < "3.0"
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
      else
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
end
