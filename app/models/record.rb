class Record < ApplicationRecord
  # Constants
  HEADERS = [ "item_name", "quantity", "unit_price", "category", "status", "customer", "created_on" ]

  # Validations
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :category, presence: true
  validates :variant_id, presence: true, unless: -> { service? }
  validate :variant_stock_quantity

  # Associations
  belongs_to :user
  belongs_to :customer, class_name: "User", optional: true
  belongs_to :variant, optional: true
  belongs_to :service_item, optional: true

  # Enums
  enum :category, %i[retail supply service loss]
  enum :status, %i[paid unpaid revert]

  def revert_sale
    Record.transaction do
      set_variant_stock(:revert)
      variant.save!
      revert!
    end
  end

  def self.add_record(attrs)
    current_user = attrs.delete(:current_user)
    customer_attrs = attrs.delete(:customer)

    new_record = new(attrs)
    transaction do
      new_record.set_variant_stock(:add)
      new_record.find_or_create_customer(current_user, customer_attrs)

      new_record.save!
      new_record.variant.save! if new_record.variant.present?
      new_record.customer.save! if new_record.customer.present?
      new_record
    end
  rescue ActiveRecord::RecordInvalid
    new_record
  end

  # Ensure to save variant after calling this method
  def set_variant_stock(method)
    return unless variant
    return unless quantity
    return if service?

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
  end

  def find_or_create_customer(current_user, attrs)
    return if self.customer_id? || attrs.nil?

    password = SecureRandom.hex(8)
    new_customer = current_user.customers
                                .build(attrs.merge(password:, password_confirmation: password))
    new_customer.valid?
    self.customer = new_customer
  rescue ActiveRecord::RecordInvalid
    self.customer = new_customer
    raise
  end

  private

  def variant_stock_quantity
    return true unless category.in?([ "retail", "supply" ])
    return true unless quantity.present?
    return true unless variant.present?
    return true unless quantity > variant.quantity

    errors.add(:quantity, I18n.t("records.errors.exceeds_stock_quantity"))
    false
  end
end
