class User < ApplicationRecord
  validates :netid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  VALID_ROLES = %w[student admin].freeze
  validates :role, inclusion: { in: VALID_ROLES }, allow_nil: true

  has_many :leet_code_sessions, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end
end
