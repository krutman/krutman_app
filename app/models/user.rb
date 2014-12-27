class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy #реализация ассоциации. опция destroy сообщает, что при удалении user его сообщения должны быть уничтожены
  before_save { email.downcase! }
  before_create :create_remember_token
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  def feed #поток сообщений, предварительное решение
    Micropost.where("user_id = ?", id) #знак "?" гарантирует, что id корректно маскирован прежде чем быть включенным в лежащий в его основе SQL запрос
  end #на данный момент Micropost.where("user_id = ?", id) эквивалетно коду microposts

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
