class Link < ActiveRecord::Base
  validates :word1_id, presence: true,
    uniqueness: {scope: :word2_id}
  validates :word2_id, presence: true

  belongs_to :word1, class_name: "Word"#, foreign_key: 'word1_id'
  belongs_to :word2, class_name: "Word"#, foreign_key: 'word2_id'
end
