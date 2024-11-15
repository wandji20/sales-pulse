module StocksHelper
  def stock_operations
    Constants::STOCK_OPERATIONS.map { |op| [ t("stocks.operations.#{op}"), op ] }
  end
end
