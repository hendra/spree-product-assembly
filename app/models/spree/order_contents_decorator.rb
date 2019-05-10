module Spree
  module OrderContents::SpreeProductAssemblyExtension
    private

    def add_to_line_item(variant, quantity, options = {})
      return super if variant.parts_variants.none?

      line_item = super
      return line_item if line_item.errors.present?

      populate_part_line_items line_item, variant.parts_variants, options["selected_variants"]

      line_item
    end

    def populate_part_line_items(line_item, parts, selected_variants)
      parts.each do |part|
        part_line_item = line_item.part_line_items.find_or_initialize_by(
          line_item: line_item,
          variant_id: variant_id_for(part, selected_variants)
        )

        part_line_item.update_attributes!(quantity: part.count)
      end
    end

    def variant_id_for(part, selected_variants)
      if part.variant_selection_deferred?
        selected_variants[part.part.id.to_s]
      else
        part.part.id
      end
    end
  end

  OrderContents.prepend OrderContents::SpreeProductAssemblyExtension
end
