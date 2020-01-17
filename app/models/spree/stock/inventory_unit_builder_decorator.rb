module Spree
  module Stock
    InventoryUnitBuilder.class_eval do
      def units
        @order.line_items.flat_map do |line_item|
          line_item.quantity_by_variant.flat_map do |variant, quantity|
            if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.3.0')
              build_inventory_unit(variant, line_item, quantity)
            else
              quantity.times.map { build_inventory_unit(variant, line_item) }
            end
          end
        end
      end

      def build_inventory_unit(variant, line_item, quantity)
        Spree::InventoryUnit.new(
          pending: true,
          line_item_id: line_item.id,
          variant_id: variant.id,
          quantity: quantity,
          order_id: @order.id
        )
      end
    end
  end
end
