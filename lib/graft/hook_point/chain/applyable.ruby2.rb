# frozen_string_literal: true

module Graft
  class HookPoint
    module Chain
      module Applyable
        def apply(obj, suffix, *args, &block)
          obj.send(:"#{method_name}_without_#{suffix}", *args, &block)
        end
      end
    end
  end
end
