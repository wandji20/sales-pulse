class Record < ApplicationRecord
  # Validations
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :category, presence: true

  # Associations
  belongs_to :user
  belongs_to :variant, optional: true
  belongs_to :service_item, optional: true

  # Enums
  enum :category, %i[sale service]
  enum :status, %i[paid unpaid]
end
