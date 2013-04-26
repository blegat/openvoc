class Inclusion < ActiveRecord::Base
  belongs_to :list
  belongs_to :word
  belongs_to :author, class_name: "User"

  validates :list_id, presence: true
  validates :word_id, presence: true,
    uniqueness: { scope: :list_id }
  validates :author_id, presence: true
end
# == Schema Information
# Schema version: 20130216160939
#
# Table name: inclusions
#
#  id         :integer         not null, primary key
#  list_id    :integer
#  word_id    :integer
#  author_id  :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
# Indexes
#
#  index_inclusions_on_list_id  (list_id)
#

