require "minitest/spec"
require "minitest/autorun"
require "spec_helper"

require "graft/stack"

describe Graft::Stack do
  describe "#initialize" do
    it do
      stack = Graft::Stack.new

      _(stack).must_be_kind_of(Array)
      _(stack).must_be :empty?
    end
  end

  describe "#call" do
    it "executes the callable objects in the stack in order" do
      called = []

      stack = Graft::Stack.new
      stack << proc { |s, env|
        called << "A+"
        s.call(env)
        called << "A-"
        :a
      }
      stack << proc { |s, env|
        called << "B+"
        s.call(env)
        called << "B-"
        :b
      }
      stack << proc { |s, env|
        called << "C+"
        called << "C-"
        :c
      }

      result = stack.call({})

      _(result).must_be :==, :a
      _(called).must_be :==, ["A+", "B+", "C+", "C-", "B-", "A-"]
    end
  end

  describe "#head" do
    it do
      stack = Graft::Stack.new([:a, :b, :c])

      _(stack.head).must_be :==, :a
    end
  end

  describe "#tail" do
    it do
      stack = Graft::Stack.new([:a, :b, :c])

      tail = stack.tail

      _(tail).must_be_instance_of(Graft::Stack)
      _(tail).must_be :==, [:b, :c]
    end

    it do
      stack = Graft::Stack.new([])

      tail = stack.tail

      _(tail).must_be_instance_of(Graft::Stack)
      _(tail).must_be :empty?
    end
  end
end
