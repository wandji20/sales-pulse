class DashboardController < ApplicationController
  before_action :set_products, only: %i[index search_products]
  before_action :set_variants, only: %i[index search_variants]
  def index
  end

  def search_products
    render turbo_stream: turbo_stream.replace("product-options",
      partial: "dashboard/search/products",
        locals: { products: @products, selected: params[:product_ids] || [],
          list_class:  @products.present? ? "" : "hidden" })
  end

  def search_variants
    render turbo_stream: turbo_stream.replace("variant-options",
      partial: "dashboard/search/variants",
        locals: { variants: @variants, selected: params[:variant_ids] || [],
          list_class:  @variants.present? ? "" : "hidden" })
  end

  private

  def set_products
    @products =
      current_user.products
                  .where("products.name LIKE ?", "%#{Product.sanitize_sql_like(params[:search] || '')}%")
                  .select("products.id, products.name")
                  .order("products.name")


    if params[:product_ids].present?
      @products = (current_user.products.where.not(id: params[:product_ids]) + @products).take(10)
    end
  end

  def set_variants
    @variants =
      current_user.products
                  .joins(:variants)
                  .where(id: params[:product_ids])
                  .where("variants.name LIKE ?", "%#{Variant.sanitize_sql_like(params[:search] || '')}%")
                  .select("variants.id, variants.name")
                  .order("variants.name")

    if params[:variant_ids]
      @variants = current_user.products.joins(:variants)
                                       .where(id: params[:product_ids])
                                       .where("variants.id IN ?", params[:variant_ids]) +
                    @variants.where.not("variants.id IN ?", params[:variant_ids])
    end
  end
end
