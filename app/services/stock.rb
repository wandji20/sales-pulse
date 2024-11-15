class Stock
  attr_reader :errors, :operation, :quantity, :stock_threshold, :show_stock_threshold, :id

  def initialize(operation = nil, quantity = nil, variant = nil, stock_threshold = nil, show_stock_threshold = false)
    @operation = operation
    @quantity = quantity
    @variant = variant
    @stock_threshold = stock_threshold
    @errors = default_errors
    @show_stock_threshold = show_stock_threshold
  end

  def save
    return false unless valid?

    update_variant_stock!
    true
  rescue => e
    p e
    false
  end

  def valid?
    validate!
    !@errors.values.map { |e| e.any? }.any?
  end

  private

  def update_variant_stock!
    previous_quantity = @variant.quantity
    @quantity = @quantity.to_i
    @show_stock_threshold = @show_stock_threshold == "1" ? true : false
    case @operation
    when "add"
      new_quantity = previous_quantity + @quantity
    when "remove"
      new_quantity = previous_quantity - @quantity
    when "set"
      new_quantity = @quantity
    else
      raise "No a valid operation"
    end

    if new_quantity < 0
      @errors[:quantity] << I18n.t("stocks.errors.negative_quantity")
      raise "invalid quantity"
    end

    @variant.update!(quantity: new_quantity, previous_quantity:, stock_threshold: @stock_threshold)
  end

  def validate!
    @errors = default_errors

    @errors[:operation] << I18n.t("stocks.errors.blank") if @operation.nil?
    unless @operation.in?(Constants::STOCK_OPERATIONS)
      @errors[:operation] << I18n.t("stocks.errors.inclusion", options: Constants::STOCK_OPERATIONS.join(", "))
    end
    @errors[:quantity] << I18n.t("stocks.errors.blank") unless @quantity.present?
    @errors[:stock_threshold] << I18n.t("stocks.errors.blank") if @show_stock_threshold && !@stock_threshold.present?
    if @show_stock_threshold && @stock_threshold.present? && @stock_threshold.to_i <= 0
      @errors[:stock_threshold] << I18n.t("stocks.errors.numericality", value: 0)
    end
  end

  def default_errors
    { operation: [], quantity: [], stock_threshold: [] }
  end
end
