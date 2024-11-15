class User < ApplicationRecord
  # Serialize the settings column as JSON
  serialize :settings, coder: ActiveRecord::Coders::JSON

  # Hooks
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  before_save -> { self.settings = default_settings }

  enum :role, %i[customer admin]

  has_secure_password
  # Associations
  has_one_attached :avatar
  has_many :sessions, dependent: :destroy
  has_many :products, dependent: :destroy

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
  validates :telephone, format: { with: /\A\d{9}\z/ }, unless: -> { telephone.blank? }

  validates :full_name, presence: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) },
            on: :update
  validate :settings_structure

  private

  def settings_structure
    errors.add(:settings, :format) unless settings.is_a?(Hash)
  end

  def default_settings
    { notifications: {
      low_stock_reminder: true,
      end_of_day_sales: true
    },
    preferences: {
      end_of_day_time: "19:00",
      show_profit_on_sales: false
    } }
  end
end
