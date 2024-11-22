class Record < ApplicationRecord
  # Constants
  HEADERS = [ "item_name", "quantity", "unit_price", "category", "status", "customer", "created_on", "actions" ]

  # Validations
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }, unless: -> { service? }
  validates :status, presence: true
  validates :category, presence: true
  validates :variant_id, presence: true, unless: -> { service? }
  validate :variant_stock_quantity
  validate :service_item_presence

  # Associations
  belongs_to :user
  belongs_to :customer, class_name: "User", optional: true
  belongs_to :variant, optional: true
  belongs_to :service_item, optional: true

  # Enums
  enum :category, %i[retail supply service loss]
  enum :status, %i[paid unpaid revert]

  def name
    return service_item.name if service? && service_item_id?
    return variant.name if !service? && variant_id?

    I18n.t("records.item")
  end

  def variant_name
    return if service?

    attributes["variant_name"] || variant&.escape_value(:name)
  end

  def item_name
    return unless service?

    attributes["item_name"] || service_item&.escape_value(:name)
  end

  def customer_name
    attributes["customer"] || customer&.escape_value(:full_name)
  end

  def update_record(attrs)
    Record.transaction do
      set_variant_stock(:edit, attrs)
      variant.save! if variant.present?
      attrs.select! { |k, _v| [ :status, :category, :unit_price ].include?(k.to_sym) }
      update!(attrs)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def revert_sale
    Record.transaction do
      set_variant_stock(:revert)
      variant.save! if variant.present?
      revert!
    end
  end

  def self.add_record(attrs)
    customer_attrs = attrs.delete(:customer)
    service_item_attrs = attrs.delete(:service_item)

    new_record = new(attrs)
    transaction do
      new_record.set_variant_stock(:add)
      new_record.find_or_create_customer(customer_attrs)
      new_record.find_or_create_service_item(service_item_attrs)

      new_record.save!
      new_record.variant.save! if new_record.variant.present?
      new_record.customer.save! if new_record.customer.present?
      new_record.service_item.save! if new_record.service_item.present?
      new_record
    end
  rescue ActiveRecord::RecordInvalid
    new_record
  end

  # Ensure to save variant after calling this method
  def set_variant_stock(method, attrs = nil)
    return if service?
    return unless variant
    return unless quantity

    previous_quantity = variant.quantity
    variant.previous_quantity = previous_quantity
    case method
    when :add
      variant.quantity = previous_quantity - quantity
    when :edit
      if attrs[:quantity].present?
        difference = quantity - attrs[:quantity].to_i
        variant.quantity = variant.quantity + difference
      end
      self.quantity = attrs[:quantity]
    when :revert
      variant.quantity = previous_quantity + quantity
      self.status = "revert"
    else
      raise "Undefined method #{method}"
    end
  end

  def find_or_create_customer(attrs)
    return if self.customer_id? || attrs.nil?

    password = SecureRandom.hex(8)
    new_customer = user.customers
                                .build(attrs.merge(password:, password_confirmation: password))
    new_customer.valid?
    self.customer = new_customer
  end

  def find_or_create_service_item(attrs)
    return unless attrs

    new_service_item = user.service_items.build(attrs)
    new_service_item.valid?
    self.service_item = new_service_item
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

  def service_item_presence
    # Add blank error when not a new item and no service_item_id is available
    if service? && !service_item.present?
      errors.add(:service_item_id, :blank)
      return false
    end

    true
  end
end
