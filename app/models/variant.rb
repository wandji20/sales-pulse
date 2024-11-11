class Variant < ApplicationRecord
  belongs_to :product

  validates :name, presence: true,
            uniqueness: { scope: :product_id },
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) }
  validates :price, presence: true,
            numericality: { in: (Constants::MIN_PRICE..Constants::MAX_PRICE) }
end
