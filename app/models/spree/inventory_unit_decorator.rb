module Spree::InventoryUnit::ProductAssemblyExtension
  module MethodOverrides
    def percentage_of_line_item
      return super unless line_item.product.assembly?

      total_value = line_item.quantity_by_variant.map { |part, quantity| part.price * quantity }.sum
      variant.price * quantity / total_value
    end

    def required_quantity
      return super if exchanged_unit? || !line_item.product.assembly?

      @required_quantity ||= line_item.quantity_by_variant[variant]
    end
  end

  def self.included(receiver)
    receiver.prepend MethodOverrides
  end
end

Spree::InventoryUnit.include Spree::InventoryUnit::ProductAssemblyExtension
