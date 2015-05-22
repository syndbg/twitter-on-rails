class User < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    length: { maximum: 250 }
  has_secure_password
  validates :password, length: { minimum: 6 }

  before_save do
    self.email = email.downcase
  end
end
