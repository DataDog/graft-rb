require "graft/hook"

RSpec.describe Graft::Hook do
  describe ".[]" do
    around do |example|
      described_class.instance_variable_get(:@hooks).clear
      example.run
      described_class.instance_variable_get(:@hooks).clear
    end

    context "when given a string" do
      it do
        described_class["Dummy#dog"]

        hooks = described_class.instance_variable_get(:@hooks)

        expect(hooks.length).to eq(1)
        expect(hooks).to have_key("Dummy#dog")
        expect(hooks.values).to all(be_instance_of(described_class))

        described_class["Dummy#dog"]

        expect(hooks.length).to eq(1)
        expect(hooks).to have_key("Dummy#dog")
        expect(hooks.values).to all(be_instance_of(described_class))
      end
    end

    context "when given a HookPoint" do
      it do
        hook_point = Graft::HookPoint.new("Dummy#dog")
        described_class[hook_point]

        hooks = described_class.instance_variable_get(:@hooks)

        expect(hooks.length).to eq(1)
        expect(hooks).to have_key(hook_point)
        expect(hooks.values).to all(be_instance_of(described_class))

        another_hook_point = Graft::HookPoint.new("Dummy#dog")
        described_class[another_hook_point]

        expect(hooks.length).to eq(2)
        expect(hooks).to have_key(another_hook_point)
        expect(hooks.values).to all(be_instance_of(described_class))
      end
    end
  end

  describe ".add" do
    around do |example|
      described_class.instance_variable_get(:@hooks).clear
      example.run
      described_class.instance_variable_get(:@hooks).clear
    end

    context "when given a string" do
      it do
        hooks = described_class.instance_variable_get(:@hooks)

        invoked = false
        self_within_the_block = nil

        described_class.add("Dummy#dog") do
          # Do something
          invoked = true
          self_within_the_block = self
        end

        expect(invoked).to be(true)
        expect(self_within_the_block).to be_instance_of(described_class)

        hooks = described_class.instance_variable_get(:@hooks)
        expect(hooks.length).to eq(1)
      end
    end

    context "when given a HookPoint" do
      it do
        hooks = described_class.instance_variable_get(:@hooks)
        hook_point = Graft::HookPoint.new("Dummy#dog")

        invoked = false
        self_within_the_block = nil

        described_class.add(hook_point) do
          # Do something
          invoked = true
          self_within_the_block = self
        end

        expect(hooks.length).to eq(1)
        expect(hooks).to have_key(hook_point)
        expect(hooks.values).to all(be_instance_of(described_class))

        another_hook_point = Graft::HookPoint.new("Dummy#dog")
        described_class[another_hook_point]

        expect(hooks.length).to eq(2)
        expect(hooks).to have_key(another_hook_point)
        expect(hooks.values).to all(be_instance_of(described_class))
      end
    end
  end

  describe ".ignore" do
    context "when given a block" do
      it do
        expect(Thread.current[:hook_entered]).to be_falsey

        described_class.ignore do
          expect(Thread.current[:hook_entered]).to be_truthy
        end

        expect(Thread.current[:hook_entered]).to be_falsey
      end
    end

    context "when given a block that raises an error" do
      it do
        expect(Thread.current[:hook_entered]).to be_falsey

        expect do
          described_class.ignore do
            expect(Thread.current[:hook_entered]).to be_truthy
            raise "Error"
          end
        end.to raise_error("Error")

        expect(Thread.current[:hook_entered]).to be_falsey
      end
    end
  end

  describe "#initialize" do
    context "when given a string" do
      it do
        hook = described_class.new("Dummy#dog")

        expect(hook).to be_enabled

        expect(hook.instance_variable_get(:@point)).to be_instance_of(Graft::HookPoint)
        expect(hook.instance_variable_get(:@stack)).to be_instance_of(Graft::Stack)
      end
    end

    context "when given a HookPoint" do
      it do
        hook_point = Graft::HookPoint.new("Dummy#dog")
        hook = described_class.new(hook_point)

        expect(hook).to be_enabled

        expect(hook.instance_variable_get(:@point)).to be_instance_of(Graft::HookPoint)
        expect(hook.instance_variable_get(:@stack)).to be_instance_of(Graft::Stack)
      end
    end
  end
end
