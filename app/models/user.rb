class User < ApplicationRecord
  validates :netid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :personal_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  VALID_ROLES = %w[student admin].freeze
  validates :role, inclusion: { in: VALID_ROLES }, allow_nil: true

  has_many :leet_code_sessions, dependent: :destroy
  has_many :events

  scope :active, -> { where(active: true) }
  scope :with_email, -> { where.not(email: nil) }

  def full_name
    "#{first_name} #{last_name}"
  end
end
