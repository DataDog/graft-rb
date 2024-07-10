# frozen_string_literal: true

module Graft
  class Stack < Array
    class EmptyStackError < StandardError; end

    def call(env = {})
      head.call(tail, env)
    end

    def head
      head = first

      raise EmptyStackError if head.nil?

      head
    end

    def tail
      tail = self[1..size]

      # TODO: raise EmptyStackError?
      return Stack.new if tail.nil?

      Stack.new(tail)
    end
  end
end
