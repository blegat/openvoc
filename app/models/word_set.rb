class WordSet < ActiveRecord::Base
  belongs_to :user
  belongs_to :list
  
  validates :user_id, presence: true
  #validates :list_id, presence: true
  validates :word1_id, presence: true
  validates :word2_id, presence: true
  validates :meaning1_id, presence: true
  validates :meaning2_id, presence: true
  
  
end
