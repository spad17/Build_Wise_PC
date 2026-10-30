class Review < ApplicationRecord
  belongs_to :user
  belongs_to :component
  validates :rating, inclusion: { in: 1..5 }
  validates :body, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :component_id, message: "уже оставил отзыв об этой детали" }
end
