module DashboardHelper
  def period_options
    [
      [ "days", t("dashboard.index.periods.days") ],
      [ "months", t("dashboard.index.periods.months") ],
      [ "years", t("dashboard.index.periods.year") ]
    ]
  end

  def month_options
    Date::ABBR_MONTHNAMES.compact.map(&:downcase).map do |month|
      [ t("date.#{month}"), month ]
    end
  end

  def year_options(user)
    products = user.products.order(:created_at)
    (products.first.created_at.strftime("%Y").to_i..products.last.created_at.strftime("%Y").to_i).to_a.map { |year| [ year, year ] }
  end
end
