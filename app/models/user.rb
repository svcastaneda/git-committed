class User < ActiveRecord::Base
  has_secure_password

  belongs_to :gender
  belongs_to :sexual_orientation
  belongs_to :sexual_preference
  has_many :text_editors
  has_many :oss

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true, allow_nil: true, length: {minimum: 8, maximum: 25}
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :zip_code, presence: true
  validates :birthday, presence: true

  def calculate_age(birthday)
    (Date.today - birthday).to_i / 365
  end
end
