module RecordsHelper
  def header_class(header)
    "min-w-[100px] sticky top-0"
  end

  def form_statuses
    Record.statuses.except(:revert).keys.map { |status| [ status, t("records.sales_form.status.#{status}") ] }
  end

  def form_categories
    Record.categories.except(:service).keys.map { |category| [ category, t("records.sales_form.category.#{category}") ] }
  end
end
