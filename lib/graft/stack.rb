# frozen_string_literal: true

module Graft
  class Stack < Array
    def call(env = {})
      head.call(tail, env)
    end

    def head
      # TODO: raise EmptyStackError?

      first
    end

    def tail
      tail = self[1..size]

      # TODO: raise EmptyStackError?
      return Stack.new if tail.nil?

      Stack.new(tail)
    end
  end
end
