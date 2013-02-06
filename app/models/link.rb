class Link < ActiveRecord::Base
  validates :word1, presence: true
  validates :word2, presence: true

  belongs_to :word1, class_name: "Word"#, foreign_key: 'word1_id'
  belongs_to :word2, class_name: "Word"#, foreign_key: 'word2_id'
end
