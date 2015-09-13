class LinkVote < ActiveRecord::Base
  belongs_to :link
  validates :link_id, presence: true
  
  belongs_to :user
  validates :user_id, presence: true
end
