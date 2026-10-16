require "uri"

class User < ApplicationRecord
  has_secure_password
  has_many :builds, dependent: :destroy

  before_validation :normalize_email

  validates :username, presence: true, length: { maximum: 50 }
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "имеет неверный формат" },
                    uniqueness: { case_sensitive: false }

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
