class Inclusion < ActiveRecord::Base
  belongs_to :list
  belongs_to :word
  belongs_to :author, class_name: "User"
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

