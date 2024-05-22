require "minitest/spec"
require "minitest/autorun"

require "graft/hook"

describe Graft::Hook do
  describe ".[]" do
    before { Graft::Hook.instance_variable_get(:@hooks).clear }
    after { Graft::Hook.instance_variable_get(:@hooks).clear }

    describe "when given a string" do
      it do
        Graft::Hook["Dummy#dog"]

        hooks = Graft::Hook.instance_variable_get(:@hooks)

        _(hooks.length).must_be :==, 1
        _(hooks).must_be :key?, "Dummy#dog"

        hooks.values.each do |v|
          _(v).must_be_kind_of Graft::Hook
        end

        Graft::Hook["Dummy#dog"]

        _(hooks.length).must_be :==, 1
        _(hooks).must_be :key?, "Dummy#dog"

        hooks.values.each do |v|
          _(v).must_be_kind_of Graft::Hook
        end
      end
    end

    describe "when given a HookPoint" do
      it do
        hook_point = Graft::HookPoint.new("Dummy#dog")
        Graft::Hook[hook_point]

        hooks = Graft::Hook.instance_variable_get(:@hooks)

        _(hooks.length).must_be :==, 1
        _(hooks).must_be :key?, hook_point

        hooks.values.each do |v|
          _(v).must_be_kind_of Graft::Hook
        end

        another_hook_point = Graft::HookPoint.new("Dummy#dog")
        Graft::Hook[another_hook_point]

        _(hooks.length).must_be :==, 2
        _(hooks).must_be :key?, another_hook_point

        hooks.values.each do |v|
          _(v).must_be_kind_of Graft::Hook
        end
      end
    end
  end

  describe ".add" do
    before { Graft::Hook.instance_variable_get(:@hooks).clear }
    after { Graft::Hook.instance_variable_get(:@hooks).clear }

    describe "when given a string" do
      it do
        invoked = false
        self_within_the_block = nil

        Graft::Hook.add("Dummy#dog") do
          # Do something
          invoked = true
          self_within_the_block = self
        end

        _(invoked).must_equal true
        _(self_within_the_block).must_be_kind_of(Graft::Hook)

        hooks = Graft::Hook.instance_variable_get(:@hooks)
        _(hooks.length).must_be :==, 1

        hooks.values.each do |v|
          _(v).must_be_kind_of Graft::Hook
        end
      end
    end

    describe "when given a HookPoint" do
      it do
        hooks = Graft::Hook.instance_variable_get(:@hooks)
        hook_point = Graft::HookPoint.new("Dummy#dog")

        invoked = false
        self_within_the_block = nil

        Graft::Hook.add(hook_point) do
          # Do something
          invoked = true
          self_within_the_block = self
        end

        _(invoked).must_equal true
        _(self_within_the_block).must_be_kind_of(Graft::Hook)

        _(hooks.length).must_be :==, 1
        _(hooks).must_be :key?, hook_point

        hooks.values.each do |v|
          _(v).must_be_kind_of Graft::Hook
        end
      end
    end
  end

  describe ".ignore" do
    describe "when given a block" do
      it do
        _(!!Thread.current[:hook_entered]).must_equal false

        Graft::Hook.ignore do
          _(!!Thread.current[:hook_entered]).must_equal true
        end

        _(!!Thread.current[:hook_entered]).must_equal false
      end
    end

    describe "when given a block that raises an error" do
      it do
        _(!!Thread.current[:hook_entered]).must_equal false

        _ do
          Graft::Hook.ignore do
            _(!!Thread.current[:hook_entered]).must_equal true
            raise "Error"
          end
        end.must_raise("Error")

        _(!!Thread.current[:hook_entered]).must_equal false
      end
    end
  end

  describe "#initialize" do
    describe "when given a string" do
      it do
        hook = Graft::Hook.new("Dummy#dog")

        _(hook).must_be :enabled?

        _(hook.instance_variable_get(:@point)).must_be_kind_of Graft::HookPoint
        _(hook.instance_variable_get(:@stack)).must_be_kind_of Graft::Stack
      end
    end

    describe "when given a HookPoint" do
      it do
        hook_point = Graft::HookPoint.new("Dummy#dog")
        hook = Graft::Hook.new(hook_point)

        _(hook).must_be :enabled?

        _(hook.instance_variable_get(:@point)).must_be_kind_of Graft::HookPoint
        _(hook.instance_variable_get(:@stack)).must_be_kind_of Graft::Stack
      end
    end
  end
end
