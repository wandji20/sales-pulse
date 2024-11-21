class RecordsController < ApplicationController
  before_action :set_record, only: %i[edit update revert]
  def index
    @records = current_user.records
                           .left_outer_joins(:variant, :customer, :service_item)
                           .select("records.*, variants.name AS 'variant_name',
                              users.full_name AS 'customer', service_items.name AS 'item_name'")
                           .order(created_at: :desc)
  end

  def create
    @record = current_user.records.add_record(record_attrs)

    if @record.persisted?
      name = @record.service? ? @record.service_item.name : @record.variant.name
      flash[:success] = t("records.create_success", name:, category: @record.category)
      redirect_to root_path
    else
      if @record.service?
        @service_items = set_service_items(params[:search_service_items] || "")
      else
        @variants = set_variants(params[:search_variant] || "")
        @customers = set_customers(params[:search_customer] || "")
      end

      render :new, status: :unprocessable_entity
    end
  end

  def new
    @record = current_user.records.new(category: params[:category])
    if @record.service?
      @service_items = set_service_items(params[:search_service_items] || "")
    else
      @variants = set_variants(params[:search_variants] || "")
      @customers = set_customers(params[:search_customers] || "")
    end

    respond_to do |format|
      format.turbo_stream
      format.html
      format.json { render json: { html: render_to_string("records/new", layout: false, formats: :html) } }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.json { render json: { html: render_to_string("records/edit", layout: false, formats: :html) } }
    end
  end

  def update
    unless @record.update_record(record_params)
      render :edit, status: :unprocessable_entity
    end
  end

  def revert
    @record.revert_sale
  end

  def search_variants
    @variants = set_variants(params[:search])
  end

  def search_customers
    set_customers(params[:search])
  end

  def search_service_items
    set_service_items(params[:search])
  end

  private

  def set_customers(search_term)
    @customers =
      current_user.customers
                  .where("users.full_name LIKE ?", "%#{Record.sanitize_sql_like(search_term)}%")
                  .select("users.id, users.full_name")
                  .order("users.full_name")
                  .limit(10)
  end

  def set_variants(search_term)
    @variants =
      current_user.products
                  .joins(:variants)
                  .where("variants.name LIKE ?", "%#{Record.sanitize_sql_like(search_term)}%")
                  .where("variants.quantity > 0")
                  .select("variants.id, variants.name, variants.quantity")
                  .order("variants.name")
                  .limit(10)
  end

  def set_service_items(search_term)
    @service_items =
      current_user.service_items
                  .where("service_items.name LIKE ?", "%#{ServiceItem.sanitize_sql_like(search_term)}%")
  end

  def customer_params
    params.require(:customer).permit(:full_name, :telephone)
  end

  def record_params
    params.require(:record).permit(:unit_price, :variant_id, :quantity, :service_item_id, :status, :category, :customer_id)
  end

  def service_item_params
    params.require(:service_item).permit(:name)
  end

  def record_attrs
    attrs = record_params.merge({ user: current_user })
    if record_params[:category] == "service"
      attrs.merge!({ service_item: service_item_params }) if params[:add_new_option] == "true"
    else
      attrs.merge!({ customer: customer_params }) if params[:add_new_option] == "true"
    end
    attrs
  end

  def set_record
    @record = current_user.records.find(params[:id])
  end
end
