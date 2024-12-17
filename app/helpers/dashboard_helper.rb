module DashboardHelper
  def period_options
    Constants::PERIOD.map do |period|
      [ period, t("dashboard.index.periods.#{period}") ]
    end
  end

  def status_options
    Record.statuses.except(:revert).keys.map do |status|
      [ t("dashboard.filters.statuses.#{status}"), status ]
    end
  end

  def chart_config(type, raw_data)
    config = { type: }

    case type.to_sym
    when :bar
      config[:data] = {
        labels: raw_data.map { |option| option["name"] },
        datasets: [ {
            label: "Sales",
            data: raw_data.map { |option| option["total_price"] },
            borderWidth: 1
        } ]
      }
      config[:options] = { scales: { y: { beginAtZero: true } } }
    when :doughnut
      config[:data] = {
        labels: raw_data.map { |option| option["category"] },
        datasets: [
          {
            label: "Total Sales",
            data: raw_data.map { |option| option["total_price"] },
            hoverOffset: 4
          }
        ]
      }
    end

    config.to_json
  end

  def partition_by_product(data)
    result = []
    i = 1
    partition = [ data[0] ]
    while i  < data.length
      if data[i]["product_id"] == data[i - 1]["product_id"]
        partition << data[i]
      else
        result << partition
        partition = [ data[i] ]
      end
      i += 1
    end

    result << partition
    result
  end

  def total_sales_label(amount, period)
    period = "today" unless period.present?

    return t(".total_sales.#{period}", amount: number_to_currency(amount)) unless period == "custom"

    t(".total_sales.#{period}", amount: number_to_currency(amount), interval: params[:interval])
  end
end
