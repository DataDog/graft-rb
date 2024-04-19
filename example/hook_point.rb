#!/usr/bin/env ruby
# frozen_string_literal: true

require 'graft'

include Graft # rubocop:disable Style/MixinUsage

# trying HookPoint

require 'graft/hook_point'

puts "\n== Hookpoint =="

class A
  def hello
    puts 'A'
  end
end

p A.new.singleton_class.ancestors

hook_point = HookPoint.new('A#hello')

hook_point.install('test') do |*args, **kwargs|
  puts 'H+'
  r = super(*args, **kwargs)
  puts 'H-'
  r
end

A.new.hello

p A.new.singleton_class.ancestors

hook_point.uninstall('test')

A.new.hello

p A.new.singleton_class.ancestors

hook_point.install('test') do |*args, **kwargs|
  puts 'H+'
  r = super(*args, **kwargs)
  puts 'H-'
  r
end

A.new.hello

p A.new.singleton_class.ancestors
