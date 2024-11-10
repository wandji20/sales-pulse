class ProductsController < ApplicationController
  before_action :set_product, only: %i[ edit destroy update ]
  def index
    @products = current_user.products
                            .left_joins(:variants)
                            .group("products.id")
                            .select('products.*,
                                    COALESCE(SUM(variants.quantity), 0) as total_quantity')
    if params[:search].present?
      @products = @products.where("name LIKE ?", "%#{Product.sanitize_sql_like(params[:search])}%")
    end
  end

  def new
    @product = current_user.products.new
  end

  def create
    product = current_user.products.build(product_params)

    if product.save
      redirect_to edit_product_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      render :edit
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if false # check that product has no sales
      @type, @message = [ :alert, "can not delete product with sales" ]
      return
    end

    if @product.destroy
      @type, @message = [ :success, t("flash_delete.success", name: @product.name) ]
      @deleted = true
    end

  rescue
    @type, @message = [ :error, t("flash_delete.failure", name: @product.name) ]
    render :destroy, status: :unprocessable_entity
  end

  private

  def set_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name)
  end
end
