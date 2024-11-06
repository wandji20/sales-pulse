class User < ApplicationRecord
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_secure_password
  # Associations
  has_one_attached :avatar
  has_many :sessions, dependent: :destroy

  # Validations
  validates :email_address, presence: true, uniqueness: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, presence: true,
            length: { within: (Constants::MIN_PASSWORD_LENGTH..Constants::MAX_PASSWORD_LENGTH) },
            on: :create
  validates :password_confirmation, presence: true,
            length: { within: (Constants::MIN_PASSWORD_LENGTH..Constants::MAX_PASSWORD_LENGTH) },
            on: :create

  validates :telephone, uniqueness: true
  validates :telephone, format: { with: /\d{9}/ }, unless: -> { telephone.blank? }

  validates :full_name, presence: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) },
            on: :update
end
