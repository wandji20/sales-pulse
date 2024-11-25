class User < ApplicationRecord
  attr_accessor :with_password
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
  has_many :service_items, dependent: :destroy
  has_many :records, dependent: :destroy
  belongs_to :supplier, class_name: "User", optional: true
  has_many :customers, class_name: "User", foreign_key: :supplier_id
  has_many :notifications

  # Validations
  validates :email_address, presence: true, uniqueness: true, if: -> { !customer? || email_address.present? }
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: -> { email_address.blank? }

  validates :password, presence: true,
            length: { within: (Constants::MIN_PASSWORD_LENGTH..Constants::MAX_PASSWORD_LENGTH) },
            if: -> { validate_password }
  validates :password_confirmation, presence: true,
            length: { within: (Constants::MIN_PASSWORD_LENGTH..Constants::MAX_PASSWORD_LENGTH) },
            if: -> { validate_password }

  validates :telephone, presence: true, if: -> { customer? }
  validates :telephone, uniqueness: true, if: -> { telephone.present? || (customer? && !email_address.present?) }
  validates :telephone, format: { with: /\A\d{9}\z/ }, unless: -> { telephone.blank? }

  validates :full_name, presence: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) },
            if: -> { customer? }
  validates :full_name, presence: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) },
            on: :update
  validate :settings_structure

  def date_format
    settings.dig(:preferences, :date_format) || Constants::DEFAULT_DATE_FORMAT
  end

  private
  
  def validate_password
    return false if self.with_password == '1'

    with_password || true
  end

  def settings_structure
    errors.add(:settings, :format) unless settings.is_a?(Hash)
  end

  def default_settings
    { notifications: {
      low_stock_reminder: true,
      end_of_day_sales: true
    },
    preferences: {
      date_format: Constants::DEFAULT_DATE_FORMAT,
      end_of_day_time: "19:00",
      show_profit_on_sales: false
    } }
  end
end
