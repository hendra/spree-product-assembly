module Spree
  describe InventoryUnit, type: :model do
    let!(:order) { create(:order_with_line_items) }
    let(:line_item) { order.line_items.first }
    let(:product) { line_item.product }

    subject { InventoryUnit.create(line_item: line_item, variant: line_item.variant, order: order) }

    context 'if the unit is not part of an assembly' do
      it 'it will return the percentage of a line item' do
        expect(subject.percentage_of_line_item).to eq BigDecimal.new(1)
      end
    end

    context 'if part of an assembly' do
      let(:parts) { (1..2).map { create(:variant) } }

      before do
        product.master.parts << parts
        order.create_proposed_shipments
        order.finalize!
      end

      it 'it will return the percentage of a line item' do
        subject.line_item = line_item
      	expect(subject.percentage_of_line_item).to eq BigDecimal.new(0.5, 2)
      end
    end

    describe '#required_quantity' do
      before { line_item.update quantity: 2 }

      it 'returns the line item quantity' do
        expect(subject.required_quantity).to eq 2
      end

      context 'given an assembly product' do
        let(:assembly) { line_item.variant }
        let(:part) { create :variant }

        subject { InventoryUnit.new line_item: line_item, variant: part, order: order }

        before do
          create :assemblies_part, assembly: assembly, part: part, count: 3
          create :assemblies_part, assembly: assembly
          StockItem.update_all count_on_hand: 10
        end

        it 'should include the part count' do
          expect(subject.required_quantity).to eq 6
        end
      end
    end
  end
end
