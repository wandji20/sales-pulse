class ServiceItem < ApplicationRecord
  validates :name, presence: true,
            uniqueness: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) }

  belongs_to :user
end
