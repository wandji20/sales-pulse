class ChartData
  def initialize(params, user)
    @params = params
    @user = user
    @start_date = nil
    @end_date = nil
  end

  def self.call(params, user)
    new(params, user).prepare
  end

  def prepare
    filter_records
    set_data

    @data
  end

  private

  def filter_records
    case true
    when @params[:period] == "today"
      @start_date = DateTime.current.beginning_of_day
      @end_date = DateTime.current.end_of_day
    when @params[:period] == "yesterday"
      @start_date = DateTime.current.yesterday.beginning_of_day
      @end_date = DateTime.current.yesterday.end_of_day
    when @params[:period] == "week"
      @start_date = DateTime.current.beginning_of_week
      @end_date = DateTime.current.end_of_week
    when @params[:period] == "month"
      @start_date = DateTime.current.beginning_of_month
      @end_date = DateTime.current.end_of_month
    when @params[:period] == "custom"
      @start_date, @end_date = @params[:interval].split("to")
      @start_date = DateTime.parse(@start_date) if @start_date.present?
      @end_date = DateTime.parse(@end_date) if @end_date.present?
    end

    @records = if @start_date.present? && @end_date.present?
      @user.records.not_revert.where("records.created_at >= ? AND records.created_at <= ?", @start_date, @end_date)
    else
      @user.records.not_revert
    end

    if @params[:status].present?
      @records = @records.where(status: @params[:status])
    end

    # filter by products
    @records = @records.joins(:variant).where("variants.product_id IN (?)", @params[:product_ids]) if @params[:product_ids].present?
    # filter by variants
    @records = @records.joins(:variant).where("variants.id IN (?)", @params[:variant_ids]) if @params[:variant_ids].present?
  end

  def set_data
    pie_data = @records.select("category, SUM(records.quantity) AS total_quantity, SUM(records.quantity * records.unit_price) AS total_price")
                       .group(:category)
                       .map { |record| record.attributes }

    product_items = @records.not_service
                            .joins(variant: :product)
                            .select("variants.name, variants.product_id, SUM(records.quantity) AS total_quantity,
                                      SUM(records.quantity * unit_price) AS total_price, products.name AS product_name")
                            .order("variants.product_id, total_quantity")
                            .group("variants.product_id, variants.name")
                            .map { |record| record.attributes }

    service_items = @records.service
                            .joins(:service_item)
                            .select("service_items.name, SUM(records.quantity) AS total_quantity,
                                     SUM(records.quantity * unit_price) AS total_price")
                            .order("total_quantity")
                            .group("service_items.name")
                            .map { |record| record.attributes }

    @data = { pie_data:, bar_data: product_items + service_items }
  end
end
