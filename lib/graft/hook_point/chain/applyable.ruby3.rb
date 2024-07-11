# frozen_string_literal: true

module Graft
  class HookPoint
    module Chain
      module Applyable
        def apply(obj, suffix, *args, **kwargs, &block)
          # TODO: should be useless, see `applyable.rbs`
          # @type self: Chain & Applyable

          obj.send(:"#{method_name}_without_#{suffix}", *args, **kwargs, &block)
        end
      end
    end
  end
end
