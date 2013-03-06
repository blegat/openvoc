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

class Word < ActiveRecord::Base
  attr_accessible :content
  VALID_WORD_REGEX = /\A[[:alnum:]]+\z/
  validates :content, presence: true, length: { maximum: 64 },
    format: { with: VALID_WORD_REGEX }
  validates :language_id, presence: true

  belongs_to :owner, class_name: "User"
  validates :owner_id, presence: true
  #TODO rename it author

  belongs_to :language
  has_many :links1, class_name: "Link", dependent: :destroy, foreign_key: "word1_id"
  has_many :links2, class_name: "Link", dependent: :destroy, foreign_key: "word2_id"
  # if need has_many inclusions
  # need to add index for :word_id in table
  # :inclusions for efficiency
  def get_tos_content
    links1.map { |l| l.word2 }
  end

end
# == Schema Information
# Schema version: 20130216160939
#
# Table name: words
#
#  id          :integer         not null, primary key
#  content     :string(255)
#  language_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  link_id     :integer
#  owner_id    :integer
#
# Indexes
#
#  index_words_on_language_id  (language_id)
#  index_words_on_content      (content)
#

