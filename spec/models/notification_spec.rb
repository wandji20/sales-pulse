require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }
  let(:variant) { create(:variant, quantity: 20) }

  context "variant" do
    describe '#message' do
      it 'displays correct message for low_stock' do
        notification = create(:variant_notification, message_type: "low_stock", subjectable: variant)
        expect(notification.message).to include("/products/#{variant.product.id}/edit?variant_name=")
        expect(notification.message).to include("is running out of stock (#{variant.quantity})")
      end

      it 'displays correct message for out_of_stock' do
        notification = create(:variant_notification, message_type: "out_of_stock", subjectable: variant)
        expect(notification.message).to include("/products/#{variant.product.id}/edit?variant_name=")
        expect(notification.message).to include("is out of stock")
      end
    end
  end

  context "report" do
    describe '#message' do
      it 'displays correct message for end_of_day report' do
        notification = create(:report_notification, message_type: "end_of_day")
        # To do
        # Add dashbord generated url when added
        # expect(notification.message).to include("/products/#{variant.product.id}/edit?variant_name=")
        expect(notification.message).to include("End of day report for #{I18n.l(notification.created_at,
                                                format: notification.user.date_format)}")
      end
    end
  end
end
