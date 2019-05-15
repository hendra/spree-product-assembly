module Spree::Order::SpreeProductAssemblyExtension
  private

  def line_item_comparison_by_part_variants(line_item, options)
    return true unless line_item.parts.present? && options["selected_variants"]

    part_variant_ids = options["selected_variants"].values.map(&:to_i)
    matched = line_item.part_line_items.map(&:variant_id) & part_variant_ids

    matched == part_variant_ids
  end
end

Spree::Order.prepend Spree::Order::SpreeProductAssemblyExtension

Rails.application.config.spree.line_item_comparison_hooks << :line_item_comparison_by_part_variants