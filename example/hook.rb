#!/usr/bin/env ruby
# frozen_string_literal: true

require "graft"

include Graft # rubocop:disable Style/MixinUsage

# trying Hook

require "graft/hook"

puts "\n== Hook =="

class B
  def hello(*args, **kwargs)
    puts "B args:#{args.inspect}, kwargs:#{kwargs.inspect}"

    ["B", args, kwargs]
  end
end

Hook["B#hello"].add do
  append do |stack, env|
    puts "X+"
    r = stack.call(env)
    puts "X-"
    r.merge(foo: "bar")
  end

  append do |stack, env|
    p env
    env[:args][0] = 43
    r = stack.call(env)
  ensure
    p env
    p r
  end
end.install

p B.new.hello(42, foo: :bar)

class C
  def hello(*args, **kwargs, &block)
    puts "C args:#{args.inspect}, kwargs:#{kwargs.inspect}, block:#{block.inspect}"

    blockres = yield "foo"

    puts blockres

    ["B", args, kwargs]
  end
end

block = proc { |foo| "block: #{foo}" }
c = C.new

p c.hello(42, foo: :bar, &block)

Hook["C#hello"].add do
  append do |stack, env|
    puts "X+"
    r = stack.call(env)
    puts "X-"
    r.merge(foo: "bar")
  end

  append do |stack, env|
    p env
    env[:args][0] = 43
    r = stack.call(env)
  ensure
    p env
    p r
  end

  append do |stack, env|
    p env
    block = env[:block]
    env[:block] = proc do |foo|
      block.call(foo.dup << "bar") << "baz"
    end
    r = stack.call(env)
    p env
    p r
  end
end.install

p c.hello(42, foo: :bar, &block)
