class Record < ApplicationRecord
  # Constants
  HEADERS = [ "item_name", "quantity", "unit_price", "category", "status", "customer", "created_on" ]

  # Validations
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :category, presence: true

  # Associations
  belongs_to :user
  belongs_to :customer, class_name: "User", optional: true
  belongs_to :variant, optional: true
  belongs_to :service_item, optional: true

  # Enums
  enum :category, %i[retail supply service loss]
  enum :status, %i[paid unpaid revert]

  # Hooks
  after_validation :verify_stock_quantity

  def revert_sale
    update_variant_stock(:revert)
  end

  def self.add_record(attrs)
    transaction do
      new_record = new(attrs)
      new_record.valid? && new_record.update_variant_stock(:add)
      new_record
    end
  end

  def update_variant_stock(method)
    return save! if service?

    previous_quantity = variant.quantity
    variant.previous_quantity = previous_quantity
    case method
    when :add
      variant.quantity = previous_quantity - quantity
    when :revert
      variant.quantity = previous_quantity + quantity
      self.status = "revert"
    else
      raise "Undefined method #{method}"
    end
    variant.save!
    save!
  end

  private

  def verify_stock_quantity
    if category == "sale" && quantity > variant.quantity
      errors.add(:quantity, I18n.t("record.errors.exceeds_stock_quantity"))
      false
    end

    true
  end
end
