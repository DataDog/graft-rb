require "graft/stack"

RSpec.describe Graft::Stack do
  describe "#initialize" do
    subject(:stack) { Graft::Stack.new }

    it { is_expected.to be_a(::Array) }
    it { is_expected.to be_empty }
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

      expect(result).to eq :a
      expect(called).to eq(["A+", "B+", "C+", "C-", "B-", "A-"])
    end
  end

  describe "#head" do
    it do
      stack = Graft::Stack.new([:a, :b, :c])

      expect(stack.head).to eq(:a)
    end
  end

  describe "#tail" do
    it do
      stack = Graft::Stack.new([:a, :b, :c])

      tail = stack.tail

      expect(tail).to be_a(Graft::Stack)
      expect(tail).to eq([:b, :c])
    end

    it do
      stack = Graft::Stack.new([])

      tail = stack.tail

      expect(tail).to be_a(Graft::Stack)
      expect(tail).to eq([])
    end
  end
end
