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
  #attr_accessible :content
  #VALID_WORD_REGEX = /\A[[:alnum:]]+\z/
  validates :content, presence: true, length: { maximum: 64 }#,
    #format: { with: VALID_WORD_REGEX }
  validates :language_id, presence: true

  belongs_to :owner, class_name: "User"
  validates :owner_id, presence: true
  #TODO rename it author
  has_many :trains, dependent: :destroy

  has_many :inclusions
  has_many :lists, dependent: :destroy, through: :inclusions

  belongs_to :language
  has_many :links, class_name: "Link", dependent: :destroy, foreign_key: "word_id"

  has_many :meanings, through: :links, source: :meaning

  def common_meanings(other_word)
    # TODO use INTERSECT with to_sql
    # Meaning.find_by_sql(word.meanings.to_sql + " INTERSECT " other_word.meanings.to_sql)
    self.meanings & other_word.meanings
  end

  # if need has_many inclusions
  # need to add index for :word_id in table
  # :inclusions for efficiency
  def get_tos_content
    links1.map { |l| l.word2 }
  end

  def trained_by(user)
    not trains.where(user_id: user.id).empty?
  end

  def last_train(user)
    trains.where(user_id: user.id).order(:created_at).last
  end

  def success_count(user = nil)
    if user.nil?
      trains.where(success: true).count
    else
      trains.where(user_id: user.id).where(success: true).count
    end
  end

  def train_count(user = nil)
    if user.nil?
      trains.count
    else
      trains.where(user_id: user.id).count
    end
  end

end
# == Schema Information
# Schema version: 20130822154326
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
