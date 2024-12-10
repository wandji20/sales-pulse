class User < ApplicationRecord
  # Constants
  HEADERS = [ "full_name", "email", "telephone", "created_on", "actions" ].freeze
  
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
            on: :update, if: -> { admin? && password.present? }
  validates :password_confirmation, presence: true,
            length: { within: (Constants::MIN_PASSWORD_LENGTH..Constants::MAX_PASSWORD_LENGTH) },
            on: :update, if: -> { admin? && password.present? }

  validates :telephone, presence: true, if: -> { customer? }
  validates :telephone, uniqueness: true, if: -> { telephone.present? || (customer? && !email_address.present?) }
  validates :telephone, format: { with: /\A\d{9}\z/ }, unless: -> { telephone.blank? }

  validates :full_name, presence: true,
            length: { within: (Constants::MIN_NAME_LENGTH..Constants::MAX_NAME_LENGTH) },
            if: -> { customer? || full_name.present? }
  validate :settings_structure

  # Filters
  scope :active, -> { where(archived: false) }

  def invite_user(email_address)
    new_user = if user = User.find_by(email_address:)
                  user.invited_at = Time.current
                  user.invited_by_id = self.id
                  user
                else
                  password = SecureRandom.hex(8)
                  User.new(
                    email_address:,
                    role: "admin",
                    invited_by_id: self.id,
                    invited_at: Time.current,
                    password:, password_confirmation: password
                  )
                end

    User.transaction do
      new_user.save!
      token = new_user.generate_token_for(:invitation)
      UserMailer.invite(new_user, token).deliver_later
      new_user
    end

  rescue ActiveRecord::RecordInvalid
    new_user
  end

  generates_token_for :invitation, expires_in: 1.week do
    invited_at
  end

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
