require "graft/hook_point"

RSpec.describe Graft::HookPoint do
  describe ".parse" do
    context "when given invalid string" do
      [
        # Add more invalid strings here...
        "",
        "Dummy"
      ].each do |str|
        it { expect { described_class.parse(str) }.to raise_error(ArgumentError) }
      end

      [
        "Dummy#",
        "Dummy."
      ].each do |str|
        it do
          pending "FIXME: This is not working as expected"
          expect { described_class.parse(str) }.to raise_error(ArgumentError)
        end
      end
    end

    context "when an valid instance method notation" do
      it do
        klass_name, method_kind, method_name = described_class.parse("Dummy#foo")

        expect(klass_name).to eq :Dummy
        expect(method_kind).to eq :instance_method
        expect(method_name).to eq :foo
      end
    end

    context "when an valid class method notation" do
      it do
        klass_name, method_kind, method_name = described_class.parse("Dummy.foo")

        expect(klass_name).to eq :Dummy
        expect(method_kind).to eq :klass_method
        expect(method_name).to eq :foo
      end
    end
  end

  describe ".const_exist?" do
    context "when given a string of existing Constant" do
      it { expect(described_class.const_exist?(described_class.to_s)).to be true }
    end

    context "when given an invalid input" do
      [
        nil,
        "",
        true,
        :symbol
      ].each do |input|
        it { expect(described_class.const_exist?(input)).to be false }
      end
    end
  end

  describe ".resolve_const" do
    context "when given a string of existing Constant" do
      it { expect(described_class.resolve_const("Object")).to eql Object }
      it { expect(described_class.resolve_const("Module")).to eql Module }
      it { expect(described_class.resolve_const("Graft::HookPoint")).to eql Graft::HookPoint }

      it do
        pending "FIXME: This is not working as expected"
        expect(described_class.resolve_const("::Graft::HookPoint")).to eql Graft::HookPoint
      end
    end

    context "when given an invalid input" do
      it { expect { described_class.resolve_const(nil) }.to raise_error(ArgumentError, /const not found/) }
      it { expect { described_class.resolve_const("") }.to raise_error(ArgumentError, /const not found/) }
      it { expect { described_class.resolve_const("Foo::Bar::Baz") }.to raise_error(NameError) }
      it { expect { described_class.resolve_const("::Foo::Bar::Baz") }.to raise_error(NameError) }
    end
  end

  describe ".resolve_module" do
    context "when given a string of existing Constant" do
      it { expect(described_class.resolve_module("Object")).to eql Object }
      it { expect(described_class.resolve_module("Module")).to eql Module }
      it { expect(described_class.resolve_module("Graft::HookPoint")).to eql Graft::HookPoint }

      it do
        pending "FIXME: This is not working as expected"
        expect(described_class.resolve_module("::Graft::HookPoint")).to eql Graft::HookPoint
      end
    end

    context "when given an invalid input" do
      it { expect { described_class.resolve_module(nil) }.to raise_error(ArgumentError, /const not found/) }
      it { expect { described_class.resolve_module("") }.to raise_error(ArgumentError, /const not found/) }
      it { expect { described_class.resolve_module("Foo::Bar::Baz") }.to raise_error(NameError) }
      it { expect { described_class.resolve_module("::Foo::Bar::Baz") }.to raise_error(NameError) }

      it do
        stub_const("MyClass", "")
        expect { described_class.resolve_module("MyClass") }.to raise_error(ArgumentError, /not a Module/)
      end
    end
  end

  describe ".strategy_module" do
    context "when given :prepend" do
      it { expect(described_class.strategy_module(:prepend)).to eql Graft::HookPoint::Prepend }
    end

    context "when given :chain" do
      it { expect(described_class.strategy_module(:chain)).to eql Graft::HookPoint::Chain }
    end

    context "when given invalid" do
      it { expect { described_class.strategy_module(:dummy) }.to raise_error(Graft::HookPointError, /unknown strategy/) }
    end
  end
end
