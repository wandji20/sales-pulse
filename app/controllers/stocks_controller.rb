class StocksController < ApplicationController
  before_action :set_product
  before_action :set_variant
  before_action :set_stock, only: [ :edit, :update ]

  def edit
    respond_to do |format|
      format.html
      format.json { render json: { html: render_to_string("stocks/edit", layout: false, formats: :html) } }
      format.turbo_stream { }
    end
  end

  def update
    if @stock.save
      render :update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = current_user.products.find(params[:product_id])
  end

  def set_variant
    @variant = @product.variants.find(params[:variant_id])
  end

  def stock_params
    params.permit(:quantity, :stock_threshold, :operation, :show_stock_threshold)
  end

  def set_stock
    @stock =
    if action_name == "edit"
      show_stock_threshold = @variant.stock_threshold.present? && @variant.stock_threshold > 0
      Stock.new(nil, nil, nil, @variant.stock_threshold, show_stock_threshold)
    elsif action_name == "update"
      Stock.new(stock_params[:operation], stock_params[:quantity],
              @variant, stock_params[:stock_threshold], stock_params[:show_stock_threshold] == "1")
    end
  end
end
