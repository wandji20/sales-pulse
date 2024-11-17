class RecordsController < ApplicationController
  def index
    @records = current_user.records
                           .left_outer_joins(:variant, :customer)
                           .select("records.*, variants.name AS 'item_name', users.full_name AS 'customer'")
  end
end
