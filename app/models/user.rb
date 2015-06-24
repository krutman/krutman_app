class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy #реализация ассоциации. опция destroy сообщает, что при удалении user его сообщения должны быть уничтожены
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed #source добавлен для переопределения таблицы по умолчанию: followed_users вместо followeds
  has_many :reverse_relationships, foreign_key: "followed_id", class_name:  "Relationship", dependent: :destroy #включаем class_name, т к иначе Rails будет искать несуществующий класс ReverseRelationship
  has_many :followers, through: :reverse_relationships, source: :follower #а вот здесь source необязателен
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
    #Micropost.where("user_id = ?", id) #знак "?" гарантирует, что id корректно маскирован прежде чем быть включенным в лежащий в его основе SQL запрос
    Micropost.from_users_followed_by(self)
  end #на данный момент Micropost.where("user_id = ?", id) эквивалетно коду microposts
  
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id) #эквивалентно self.relationships.create!
  end
  
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
