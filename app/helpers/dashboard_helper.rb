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
end
