class Variant < ApplicationRecord
  belongs_to :product, counter_cache: true

  validates :name, presence: true,
            uniqueness: { scope: :product_id },
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) }
  validates :supply_price, :buying_price, presence: true,
            numericality: { in: (Constants::MIN_PRICE..Constants::MAX_PRICE) }

  def create_notification
    attrs = { delivery_type: :both, type: "Notifications::Variant", subjectable: self }

    case true
    when quantity == 0
      attrs[:message_type] = "out_of_stock"
      product.user.notifications.create!(attrs)
    when stock_threshold.present? && self.quantity <= stock_threshold
      unless low_stock_already_created
        attrs[:message_type] = "low_stock"
        product.user.notifications.create!(attrs)
      end
    end
  end

  private


  def low_stock_already_created
    # low_stock enum value is 0
    product.user.notifications
                .where(message_type: 0, subjectable_type: "Variant", subjectable_id: id)
                .joins("JOIN variants ON variants.id = notifications.subjectable_id AND notifications.subjectable_type = 'Variant'")
                .where("variants.previous_quantity <= variants.stock_threshold")
                .exists?
  end
end
