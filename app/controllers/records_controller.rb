class RecordsController < ApplicationController
  before_action :set_record, only: %i[edit update revert destroy]
  def index
    result = current_user.records
                         .left_outer_joins(:variant, :customer, :service_item)
                         .select("records.*, variants.name AS 'variant_name',
                            users.full_name AS 'customer_name', service_items.name AS 'item_name'")
                          .where("variants.name LIKE ? OR service_items.name LIKE ?",
                            "%#{Record.sanitize_sql_like(params[:search] || '')}%",
                            "%#{Record.sanitize_sql_like(params[:search] || '')}%")
                         .order(created_at: :desc)

    @pagy, @records = pagy(result)
  end

  def create
    @record = current_user.records.add_record(record_attrs)

    if @record.persisted?
      name = @record.service? ? @record.service_item.name : @record.variant.name
      flash[:success] = t("records.create_success", name:, category: @record.escape_value(:category))
      redirect_to root_path
    else
      if @record.service?
        set_service_items(params[:search_service_items] || "")
      else
        set_variants(params[:search_variant] || "")
        set_customers(params[:search_customer] || "")
      end

      render turbo_stream: turbo_stream.replace("new_record", partial: "records/form",
        locals: { record: @record, customers: @customers, variants: @variants, service_items: @service_items }),
        status: :unprocessable_entity
    end
  end

  def new
    @record = current_user.records.new(category: params[:category])
    if @record.service?
      set_service_items(params[:search_service_items] || "")
    else
      set_variants(params[:search_variants] || "")
      set_customers(params[:search_customers] || "")
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

  def destroy
    if !@record.revert?
      @type = :alert
      @message = t("records.delete_fail_revert")
    else
      @record.destroy!
      @deleted = true
      @type = :success
      @message = t("flash_delete.success", name: @record.escape_value(:name))
    end
  end

  def revert
    @record.revert_sale
  end

  def search_variants
    set_variants(params[:search])

    render turbo_stream: turbo_stream.replace("variant-options", partial: "records/search/variants",
      locals: { variants: @variants,  selected: [], list_class:  @variants.present? ? "" : "hidden" })
  end

  def search_customers
    set_customers(params[:search])

    render turbo_stream: turbo_stream.replace("customer-options", partial: "records/search/customers",
      locals: { customers: @customers,  selected: [], list_class:  @customers.present? ? "" : "hidden" })
  end

  def search_service_items
    set_service_items(params[:search])

    render turbo_stream: turbo_stream.replace("service-item-options", partial: "records/search/service_items",
      locals: { service_items: @service_items,  selected: [], list_class:  @service_items.present? ? "" : "hidden" })
  end

  private

  def set_customers(search_term)
    @customers =
      current_user.customers
                  .where("users.full_name LIKE ?", "%#{Record.sanitize_sql_like(search_term)}%")
                  .select("users.id, users.full_name")
                  .order("users.full_name")
                  .limit(10)

    if @record&.customer_id?
      @customers = current_user.customers.where(id: @record.customer_id) +
                      @customers.where.not(id: @record.customer_id)
    end
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

    if @record&.variant_id?
      @variants = current_user.products.joins(:variants)
                              .where("variants.id = ?", @record.variant_id)
                              .select("variants.id, variants.name, variants.quantity") +
                              @variants.where.not("variants.id = ?", @record.variant_id)

    end
  end


  def set_service_items(search_term)
    @service_items =
      current_user.service_items
                  .where("service_items.name LIKE ?", "%#{ServiceItem.sanitize_sql_like(search_term)}%")
                  .order(:name)

    if @record&.service_item_id?
      @service_items = current_user.service_items.where(id: @record.service_item_id) +
                        @service_items.where.not(id: @record.service_item_id)
    end
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
