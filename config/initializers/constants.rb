class Constants
  # Min characters for short text fields
  MIN_NAME_LENGTH = 2
  # Max characters for short text fields
  MAX_NAME_LENGTH = 255
  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 128
  MIN_PRICE = 10
  MAX_PRICE = 1000000000

  # Stocks
  STOCK_OPERATIONS = [ "add", "remove", "set" ].freeze

  DEFAULT_DATE_FORMAT = "%d-%b-%Y".freeze

  PERIOD = [ "today", "yesterday", "week", "month", "custom" ].freeze
end
