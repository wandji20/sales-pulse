require 'rails_helper'

RSpec.describe Record, type: :model do
  let(:variant) { create(:variant, quantity: 20) }
  let(:user) { create(:user, role: :admin) }
  it { should validate_presence_of(:unit_price) }
  it { should validate_numericality_of(:unit_price).is_greater_than(0) }
  it { should validate_presence_of(:quantity) }
  it { should validate_numericality_of(:quantity).is_greater_than(0) }
  it { should validate_presence_of(:category) }
  it { should validate_presence_of(:status) }

  it { should belong_to(:user) }
  it { should belong_to(:service_item).optional }
  it { should belong_to(:variant).optional }
  it { should belong_to(:customer).class_name("User").optional }

  describe "#add_record" do
    context 'when category is retail, supply' do
      let(:attrs) do
        { variant:, user:, unit_price: variant.buying_price + 200,
          category: [ 'retail', 'supply' ].sample, quantity: 10 }
      end
      it 'adds new sale and updates variant quantity' do
        new_record = described_class.add_record(attrs)
        expect(new_record.persisted?).to be_truthy
        expect(variant.quantity).to eq(10)
        expect(variant.previous_quantity).to eq(20)
      end

      it 'reverts a sale and updates variant quantity' do
        # create sale
        new_record = described_class.add_record(attrs)
        expect(new_record.persisted?).to be_truthy
        expect(variant.quantity).to eq(10)
        expect(variant.previous_quantity).to eq(20)
        # revert sale
        new_record.revert_sale
        expect(variant.quantity).to eq(20)
        expect(variant.previous_quantity).to eq(10)
        expect(new_record.status).to eq('revert')
      end
    end
  end
end
