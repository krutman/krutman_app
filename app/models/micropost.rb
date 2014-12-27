class Micropost < ActiveRecord::Base
  belongs_to :user #ассоциация - микросообщение принадлежит пользователю
  default_scope -> { order('created_at DESC') } #упорядочевание по DESC - по убыванию (от новым к старым)
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
end
