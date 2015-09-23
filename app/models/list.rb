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

class List < ActiveRecord::Base
  #attr_accessible :name
  validates :name, presence: true
    # uniqueness: { scope: :parent } FIXME deal with root with owner

  belongs_to :owner, class_name: "User"
  validates :owner, presence: true

  has_many :childs, class_name: "List", foreign_key: :parent_id,
    dependent: :destroy
  belongs_to :parent, class_name: "List"

  #before_save :set_root_if_no_parent

  #has_many :words, dependent: :destroy, through: :inclusions
  #has_many :inclusions
  #FIXME which one is better ? why is the first one working ?
  #(i.e. passing the tests)
  has_many :words, through: :wordsets
  has_many :wordsets, dependent: :destroy, foreign_key: :list_id, class_name: "WordSet"
  has_many :trains, foreign_key: :list_id

  belongs_to :language1, class_name: "Language"
  belongs_to :language2, class_name: "Language"

  validate :language1_id, presence: true
  validate :language2_id, presence: true

  validate :parent_of_same_owner

  def parent_of_same_owner
    if not parent.nil? and owner != parent.owner
      errors.add(:list, "owner must be the same as parent's owner")
    end
  end

  def selectable_path
    if parent.nil?
      "/#{link_to name, self}"
    else
      "#{parent.path}/#{link_to name, current}"
    end
  end
  def path
    if parent.nil?
      "/#{name}"
    else
      "#{parent.path}/#{name}"
    end
  end
  def set_root_if_no_parent
    if self.parent.nil?# and not self.owner.nil?
      self.parent = self.owner.root
    end
  end

  def words_rec
    childs.inject(words.to_a) do |words, child|
      words + child.words_rec
    end
  end

  def contain_word(word)
    words.include?(word)
  end

  def add_word(word, meaning, user)
    wordset = WordSet.new
    wordset.list = self
    wordset.user = user
    wordset.word = word
    wordset.meaning = meaning
    wordset.asked_qa = 0
    wordset.success_qa = 0
    wordset.success_ratio_qa = 0.0
    wordset.asked_aq = 0
    wordset.success_aq = 0
    wordset.success_ratio_aq = 0.0
    if wordset.save
      nil
    else
      wordset.errors.full_messages.to_sentence
    end
  end

  def rec_parents
    if parent.nil?
      []
    else
      parent.rec_parents.push(parent)
    end
  end
  def lists_outside(list)
    lists = []
    is_parent = false
    if self != list
      childs.each do |cur|
        lists.concat(cur.lists_outside(list))
        if list == cur
          is_parent = true
        end
      end
      unless is_parent
        lists << self
      end
    end
    lists
  end

end
# == Schema Information
# Schema version: 20130822154326
#
# Table name: lists
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  parent_id  :integer
#  owner_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
# Indexes
#
#  index_lists_on_parent_id  (parent_id)
#  index_lists_on_owner_id   (owner_id)
#
