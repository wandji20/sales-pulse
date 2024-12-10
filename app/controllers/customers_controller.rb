class CustomersController < ApplicationController
  before_action :require_admin
  before_action :set_customer, only: %i[update edit destroy]

  def index
    customers = current_user.customers.active
    if params[:search].present?
      customers = customers.where("full_name LIKE ?", "%#{User.sanitize_sql_like(params[:search])}%")
    end

    @pagy, @records = pagy(customers.order(created_at: :desc))
  end

  def new
    @customer = current_user.customers.new

    respond_to do |format|
      format.json do
        render json: { html: render_to_string("customers/new", layout: false, formats: :html) }
      end
    end
  end

  def create
    password = SecureRandom.hex(8)
    @customer = current_user.customers.build(
      customer_params.merge({ password:, password_confirmation: password }))

    if @customer.save
      render turbo_stream: turbo_stream.prepend("customers-table",
        partial: "customers/table_row", locals: { customer: @customer })
    else
      render turbo_stream: turbo_stream.replace("customer-form",
        partial: "customers/customer_form", locals: { customer: @customer }),
        status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render turbo_stream: turbo_stream.replace("customer_user_#{@customer.id}",
      partial: "customers/table_row", locals: { customer: @customer })
    else
      render turbo_stream: turbo_stream.replace("customer-form",
        partial: "customers/customer_form", locals: { customer: @customer }),
        status: :unprocessable_entity
    end
  end

  def edit
    respond_to do |format|
      format.json do
        render json: { html: render_to_string("customers/edit", layout: false, formats: :html) }
      end
    end
  end

  def destroy
    @customer.update(archived: true)
    flash[:success] = t("flash_delete.success", name: @customer.full_name)
    redirect_back fallback_location: customers_path
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:id])
  end

  def customer_params
    params.require(:user).permit(:full_name, :email_address, :telephone)
  end
end
