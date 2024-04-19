#!/usr/bin/env ruby
# frozen_string_literal: true

require 'graft'

include Graft # rubocop:disable Style/MixinUsage

# trying Stack

puts "\n== Stack =="

require 'graft/stack'

s = Stack.new

c1 = proc do |stack, env|
  puts 'S+'
  stack.call(env)
ensure
  puts 'S-'
end

c2 = proc do |stack, env|
  puts 'T+'
  stack.call(env)
ensure
  puts 'T-'
end

s << c1
s << c2
s << proc do |_stack, env|
  p env

  42
end

p s.call({ a: 1 })
