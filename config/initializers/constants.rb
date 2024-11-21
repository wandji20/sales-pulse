class Constants
  #=============================================================================
  # String lengths
  #=============================================================================

  # Min characters for short text fields
  MIN_NAME_LENGTH = 2
  # Max characters for short text fields
  MAX_NAME_LENGTH = 255
  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 128
  MIN_PRICE = 10
  MAX_PRICE = 1000000000

  # Stocks
  STOCK_OPERATIONS = [ "add", "remove", "set" ]

  DEFAULT_DATE_FORMAT = "%d/%m/%Y".freeze
  # SUPPORTED_DATE_FORMATS = [
  #   # US formats
  #   "%m/%d/%Y", "%m.%d.%Y", "%m. %d. %Y", "%m-%d-%Y", "%-m/%-d/%Y",
  #   "%-m.%-d.%Y", "%-m. %-d. %Y", "%-m-%-d-%Y",
  #   # European formats
  #   "%d/%m/%Y", "%d.%m.%Y", "%d. %m. %Y", "%d-%b-%Y", "%Y-%m-%d",
  #   "%d.%b.%Y", "%Y/%b/%d", "%d, %B, %Y", "%B, %d, %Y", "%-d/%-m/%Y",
  #   "%-d.%-m.%Y", "%-d. %-m. %Y", "%d-%m-%Y", "%Y-%-m-%-d", "%-d-%b-%Y",
  #   "%Y-%b-%-d", "%-d, %B, %Y", "%B, %-d, %Y"
  # ].freeze
end
