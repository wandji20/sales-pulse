class VariantsController < ApplicationController
  before_action :set_product
  before_action :set_variant, only: %i[edit destroy]

  def create
    @variant = @product.variants.build(variant_params)
    if @variant.save
      @type, @message = [ :success, t("flash_delete.success", name: @variant.name) ]
      render :create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def new
    @variant = @product.variants.new
    respond_to do |format|
      format.html
      format.json { render json: { html: render_to_string("variants/new", layout: false, formats: :html) } }
    end
  end

  def destroy
    if false # check that variant has no sales
      @type, @message = [ :alert, "can not delete variant with sales" ]
      return
    end

    if @variant.destroy
      @type, @message = [ :success, t("flash_delete.success", name: @variant.name) ]
      @deleted = true
    end

  rescue
    @type, @message = [ :error, t("flash_delete.failure", name: @variant.name) ]
    render :destroy, status: :unprocessable_entity
  end

  def set_stock
  end

  private

  def set_product
    @product = current_user.products.find(params[:product_id])
  end

  def set_variant
    @variant = @product.variants.find(params[:id])
  end

  def variant_params
    params.require(:variant).permit(:name, :price)
  end
end
