require 'rails_helper'

RSpec.describe Record, type: :model do
  let(:variant) { create(:variant, quantity: 20) }
  let(:user) { create(:user, role: :admin) }
  let(:customer) { create(:user, role: :customer, supplier: user) }
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

    context "when stock threshold is reached" do
      let(:variant) { create(:variant, quantity: 100, stock_threshold: 20, buying_price: 1000) }

      it "creates a low_stock notication" do
        notification_count = Notification.count
        Record.add_record({ quantity: 80, category: 'supply', unit_price: 1200, variant:, user: })
        notification = variant.product.user.notifications.last
        expect(Notification.count).to eq(notification_count + 1)
        expect(notification.message_type).to eq('low_stock')
        # No extra notification is sent
        Record.add_record({ quantity: 10, category: 'supply', unit_price: 1200, variant:, user: })
        expect(expect(Notification.count).to eq(notification_count + 1))
        expect(variant.product.user.notifications.last.id).to eq(notification.id)
      end


      it "creates out of stock notication" do
        notification_count = Notification.count
        Record.add_record({ quantity: 80, category: 'supply', unit_price: 1200, variant:, user: })
        notification = variant.product.user.notifications.last
        expect(Notification.count).to eq(notification_count + 1)
        expect(notification.message_type).to eq('low_stock')
        # Now empty stock notification is sent
        Record.add_record({ quantity: 20, category: 'supply', unit_price: 1200, variant:, user: })
        expect(expect(Notification.count).to eq(notification_count + 2))
        expect(variant.product.user.notifications.last.message_type).to eq('out_of_stock')
      end
    end
  end

  describe "#update_record" do
    let(:variant) { create(:variant, buying_price: 175, quantity: 20) }
    let(:variant1) { create(:variant, quantity: 30) }
    let(:customer1) { create(:user, role: :customer, supplier: user) }
    let(:record) { Record.add_record({ category: 'retail', variant:, quantity: 6,
                    status: 'paid', unit_price: 250, user:, customer_id: customer.id }) }

    it "increases variant stock if quantity is reduced" do
      expect(record.variant.quantity).to eq(14)
      record.update_record({ quantity: 4, status: 'unpaid', category: 'supply' })

      expect(record.quantity).to eq(4)
      expect(record.variant.quantity).to eq(16)
      expect(record.status).to eq('unpaid')
      expect(record.category).to eq('supply')
    end

    it "decreases variant stock if quantity is increased" do
      expect(record.variant.quantity).to eq(14)
      record.update_record({ quantity: 9, status: 'unpaid', category: 'supply' })

      expect(record.quantity).to eq(9)
      expect(record.variant.quantity).to eq(11)
      expect(record.status).to eq('unpaid')
      expect(record.category).to eq('supply')
    end

    it 'only updates :status, :category, :unit_price, :quantity values' do
      expect(record.variant.quantity).to eq(14)
      record.update_record({ quantity: 9, status: 'unpaid', customer_id: customer1.id, variant_id: variant1.id })
      expect(record.quantity).to eq(9)
      expect(record.variant.quantity).to eq(11)
      expect(record.status).to eq('unpaid')
      expect(record.variant_id).to eq(variant.id)
      expect(record.variant_id).to_not eq(variant1.id)
      expect(record.customer_id).to eq(customer.id)
      expect(record.customer_id).to_not eq(customer1.id)
    end
  end
end
