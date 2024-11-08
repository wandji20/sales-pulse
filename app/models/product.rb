class Product < ApplicationRecord
  belongs_to :user
  belongs_to :archived_by, class_name: "User", optional: true
  has_many :variants, dependent: :destroy

  validates :name, presence: true,
            uniqueness: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) }

  def total
    variants.sum(:quantity)
  end
end
