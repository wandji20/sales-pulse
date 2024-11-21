require 'rails_helper'

RSpec.describe Record, type: :model do
  let(:variant) { create(:variant, quantity: 20) }
  let(:user) { create(:user, role: :admin) }
  subject { create(:record) }

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

      it "adds customer to record" do
        customer = create(:user, role: :customer, email_address: nil)
        new_record = described_class.add_record(attrs.merge({ customer_id: customer.id }))
        expect(new_record.persisted?).to be_truthy
        expect(new_record.customer_id).to eq(customer.id)
      end

      it "create and adds new customer to record" do
        new_record = described_class.add_record(
          attrs.merge({ customer: { telephone: '678452145', full_name: 'New customer' } }))
        expect(new_record.persisted?).to be_truthy
        expect(new_record.customer.telephone).to eq('678452145')
      end

      it "fails to add new customer to record" do
        new_record = described_class.add_record(attrs.merge({ customer: {} }))
        expect(new_record.persisted?).to be_falsey
        expect(new_record.customer.persisted?).to be_falsey

        expect(new_record.customer.errors.full_messages).to include(/Telephone can't be blank/)
        expect(new_record.customer.errors.full_messages).to include(/Full name can't be blank/)

        new_record = described_class.add_record(attrs.merge({ customer: { telephone: '12478', full_name: 't' } }))
        expect(new_record.customer.errors.full_messages).to include(/Telephone is invalid/)
        expect(new_record.customer.errors.full_messages).to include(/Full name is too short \(minimum is 2 characters\)/)
        expect(new_record.persisted?).to be_falsey
      end

      it 'fails to add sale when quantity exceeds variant quantity' do
        attrs[:quantity] = variant.quantity + 20

        new_record = described_class.add_record(attrs)
        expect(new_record.persisted?).to be_falsey
        expect(new_record.errors.messages[:quantity]).to include(/exceeds available stock for product item/)
      end
    end

    context 'when category is service' do
      let(:service_item) { create(:service_item, user:) }
      let(:attrs) { { user:, unit_price: 1000, category: 'service' } }

      it 'succesfully creates a record with valid attrs' do
        new_record = described_class.add_record(attrs.merge({ service_item_id: service_item.id }))
        expect(new_record.persisted?).to be_truthy
        expect(new_record.service_item_id).to eq(service_item.id)
      end

      it 'succesfully creates a record with and add service item with valid attrs' do
        new_record = described_class.add_record(attrs.merge(service_item: { name: 'new item' }))
        expect(new_record.persisted?).to be_truthy
        expect(new_record.service_item.name).to eq('new item')
      end

      it 'fails to creates a record with invalid service item attrs' do
        new_record = described_class.add_record(attrs.merge(service_item: { name: service_item.name }))
        expect(new_record.persisted?).to be_falsey
        expect(new_record.service_item.errors[:name]).to include(/has already been taken/)

        new_record = described_class.add_record(attrs.merge(service_item: { name: '' }))
        expect(new_record.persisted?).to be_falsey
        expect(new_record.service_item.errors[:name]).to include(/too short/)
      end
    end
  end
end
