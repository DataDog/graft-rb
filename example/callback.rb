#!/usr/bin/env ruby
# frozen_string_literal: true

require "graft"

include Graft # rubocop:disable Style/MixinUsage

# trying Callback

puts "\n== Callback =="

require "graft/callback"

s = Stack.new

c1 = Callback.new("c1", my: :option) do |stack, env|
  puts "S+"
  stack.call(env)
ensure
  puts "S-"
end

c2 = Callback.new("c2", other: :option) do |stack, env|
  puts "T+"
  stack.call(env)
ensure
  puts "T-"
end

s << c1
s << c2
s << proc do |_stack, env|
  p env

  42
end

p s.call({a: 1})

p c1
p c2
