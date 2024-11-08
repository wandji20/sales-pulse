class ProductsController < ApplicationController
  def index
    @products = current_user.products

    if params[:search].present?
      @products = @products.where("name LIKE ?", "%#{Product.sanitize_sql_like(params[:search])}%")
    end
  end

  def edit
  end

  def destroy
  end
end
