require "minitest/spec"
require "minitest/autorun"
require "spec_helper"

require "graft/hook_point"

describe Graft::HookPoint do
  describe ".parse" do
    describe "when given invalid string" do
      [
        # Add more invalid strings here...
        "",
        "Dummy"
      ].each do |str|
        it { _ { Graft::HookPoint.parse(str) }.must_raise(ArgumentError) }
      end

      [
        "Dummy#",
        "Dummy."
      ].each do |str|
        it do
          skip "FIXME: This is not working as expected"
          _ { Graft::HookPoint.parse(str) }.must_raise(ArgumentError)
        end
      end
    end

    describe "when an valid instance method notation" do
      it do
        klass_name, method_kind, method_name = Graft::HookPoint.parse("Dummy#foo")

        _(klass_name).must_be :==, :Dummy
        _(method_kind).must_be :==, :instance_method
        _(method_name).must_be :==, :foo
      end
    end

    describe "when an valid class method notation" do
      it do
        klass_name, method_kind, method_name = Graft::HookPoint.parse("Dummy.foo")

        _(klass_name).must_be :==, :Dummy
        _(method_kind).must_be :==, :klass_method
        _(method_name).must_be :==, :foo
      end
    end
  end

  describe ".const_exist?" do
    describe "when given a string of existing Constant" do
      it { _(Graft::HookPoint.const_exist?(Graft::HookPoint.to_s)).must_equal true }
    end

    describe "when given an invalid input" do
      [
        nil,
        "",
        true,
        :symbol
      ].each do |input|
        it { _(Graft::HookPoint.const_exist?(input)).must_equal false }
      end
    end
  end

  describe ".resolve_const" do
    describe "when given a string of existing Constant" do
      it { _(Graft::HookPoint.resolve_const("Object")).must_equal Object }
      it { _(Graft::HookPoint.resolve_const("Module")).must_equal Module }
      it { _(Graft::HookPoint.resolve_const("Graft::HookPoint")).must_equal Graft::HookPoint }

      it do
        skip "FIXME: This is not working as expected"
        _(Graft::HookPoint.resolve_const("::Graft::HookPoint")).must_equal Graft::HookPoint
      end
    end

    describe "when given an invalid input" do
      it { _ { Graft::HookPoint.resolve_const(nil) }.must_raise(ArgumentError, /const not found/) }
      it { _ { Graft::HookPoint.resolve_const("") }.must_raise(ArgumentError, /const not found/) }
      it { _ { Graft::HookPoint.resolve_const("Foo::Bar::Baz") }.must_raise(NameError) }
      it { _ { Graft::HookPoint.resolve_const("::Foo::Bar::Baz") }.must_raise(NameError) }
    end
  end

  describe ".resolve_module" do
    describe "when given a string of existing Constant" do
      it { _(Graft::HookPoint.resolve_module("Object")).must_equal Object }
      it { _(Graft::HookPoint.resolve_module("Module")).must_equal Module }
      it { _(Graft::HookPoint.resolve_module("Graft::HookPoint")).must_equal Graft::HookPoint }

      it do
        skip "FIXME: This is not working as expected"
        _(Graft::HookPoint.resolve_module("::Graft::HookPoint")).must_equal Graft::HookPoint
      end
    end

    describe "when given an invalid input" do
      it { _ { Graft::HookPoint.resolve_module(nil) }.must_raise(ArgumentError, /const not found/) }
      it { _ { Graft::HookPoint.resolve_module("") }.must_raise(ArgumentError, /const not found/) }
      it { _ { Graft::HookPoint.resolve_module("Foo::Bar::Baz") }.must_raise(NameError) }
      it { _ { Graft::HookPoint.resolve_module("::Foo::Bar::Baz") }.must_raise(NameError) }
    end

    describe "with mock" do
      before { Object.const_set(:MyClass, "") }
      after { Object.__send__ :remove_const, "MyClass" }

      it { _ { Graft::HookPoint.resolve_module("MyClass") }.must_raise(ArgumentError, /not a Module/) }
    end
  end

  describe ".strategy_module" do
    describe "when given :prepend" do
      it { _(Graft::HookPoint.strategy_module(:prepend)).must_equal Graft::HookPoint::Prepend }
    end

    describe "when given :chain" do
      it { _(Graft::HookPoint.strategy_module(:chain)).must_equal Graft::HookPoint::Chain }
    end

    describe "when given invalid" do
      it { _ { Graft::HookPoint.strategy_module(:dummy) }.must_raise(Graft::HookPointError, /unknown strategy/) }
    end
  end
end
