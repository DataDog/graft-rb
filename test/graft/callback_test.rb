require "minitest/autorun"

require "graft/callback"

class TestCallback < Minitest::Test
  def test_initialize
    callback = Graft::Callback.new

    assert_nil callback.name
  end

  def test_initialize_with_name
    name = "Tony Stark"

    callback = Graft::Callback.new(name)

    assert_equal name, callback.name
  end

  def test_enable_by_default
    callback = Graft::Callback.new

    refute_predicate callback, :disabled?

    callback.disable

    assert_predicate callback, :disabled?

    callback.enable

    refute_predicate callback, :disabled?
  end

  def invocations
    [
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
  end

  def test_without_block_call
    callback = Graft::Callback.new("name", {})

    callback.enable

    invocations.each do |i|
      assert_raises NoMethodError do
        i.call(callback)
      end
    end

    callback.disable

    invocations.each do |i|
      assert_nil i.call(callback)
    end
  end

  def test_with_block_call
    callback = Graft::Callback.new("name", {}) { :wuff }
    # NOTE: What is missing?

    callback.enable

    invocations.each do |i, v|
      assert_equal :wuff, i.call(callback)
    end

    callback.disable

    invocations.each do |i|
      assert_nil i.call(callback)
    end
  end
end
