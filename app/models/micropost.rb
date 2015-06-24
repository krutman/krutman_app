class Micropost < ActiveRecord::Base
  belongs_to :user #ассоциация - микросообщение принадлежит пользователю
  default_scope -> { order('created_at DESC') } #упорядочевание по DESC - по убыванию (от новым к старым)
  mount_uploader :picture, PictureUploader #аплоадер картинок
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  validate  :picture_size
  
  def self.from_users_followed_by(user)
    #followed_user_ids = user.followed_user_ids #аналог метода user.followed_users.map(&:id)
    #where("user_id IN (?) OR user_id = ?", followed_user_ids, user)
    #followed_user_ids = user.followed_user_ids
    #where("user_id IN (:followed_user_ids) OR user_id = :user_id", followed_user_ids: followed_user_ids, user_id: user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)
  end
  
  private

    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
