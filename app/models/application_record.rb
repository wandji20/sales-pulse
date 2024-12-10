class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def escape_value(method)
    ERB::Util.html_escape(self.try(method))
  end
end
