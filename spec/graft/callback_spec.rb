require "minitest/spec"
require "minitest/autorun"
require "spec_helper"

require "graft/callback"

describe Graft::Callback do
  describe "initialize" do
    it do
      callback = Graft::Callback.new

      _(callback.name).must_be_nil
    end

    it do
      name = "Tony Stark"

      callback = Graft::Callback.new(name)

      _(callback.name).must_be :==, name
    end

    describe "enabled?" do
      it do
        callback = Graft::Callback.new

        _(callback).must_be :enabled?

        callback.disable

        _(callback).wont_be :enabled?

        callback.enable

        _(callback).must_be :enabled?
      end
    end

    describe "#call" do
      invocations = [
        ->(c) { c.call }, # with no args
        ->(c) { c.call(:foo) }, # with positional arg
        ->(c) { c.call(:foo, :bar) }, # with 2 positional args
        ->(c) { c.call({foo: :bar}) }, # with positional arg(hash)
        ->(c) { c.call(foo: :bar) }, # with kwargs
        ->(c) { c.call { :baz } }, # with block
        ->(c) { c.call(:foo) { :baz } }, # with positional arg + block
        ->(c) { c.call(:foo, :bar) { :baz } }, # with 2 positional arg + block
        ->(c) { c.call({foo: :bar}) { :baz } }, # with positional arg(hash) + block
        ->(c) { c.call(foo: :bar) { :baz } } # with kwargs + block
        # Add more invocations here...
      ]

      it do
        callback = Graft::Callback.new("name", {})

        callback.enable

        invocations.each do |i|
          _ { i.call(callback) }.must_raise NoMethodError
        end

        callback.disable

        invocations.each do |i|
          _(i.call(callback)).must_be_nil
        end
      end

      it do
        callback = Graft::Callback.new("name", {}) { :wuff }
        # NOTE: What is missing?

        callback.enable

        invocations.each do |i, v|
          _(i.call(callback)).must_be :==, :wuff
        end

        callback.disable

        invocations.each do |i|
          _(i.call(callback)).must_be_nil
        end
      end
    end
  end
end
