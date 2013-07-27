### BEGIN LICENSE
# Copyright (C) 2012 Benoît Legat benoit.legat@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE

class Link < ActiveRecord::Base
  validates :word1_id, presence: true,
    uniqueness: { scope: :word2_id }
  validates :word2_id, presence: true

  belongs_to :owner, class_name: "User"
  validates :owner_id, presence: true
  #TODO rename it author

  belongs_to :word1, class_name: "Word"#, foreign_key: 'word1_id'
  belongs_to :word2, class_name: "Word"#, foreign_key: 'word2_id'
end
# == Schema Information
# Schema version: 20130317152821
#
# Table name: links
#
#  id         :integer         not null, primary key
#  word1_id   :integer
#  word2_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  owner_id   :integer
#
# Indexes
#
#  index_links_on_word2_id  (word2_id)
#  index_links_on_word1_id  (word1_id)
#

