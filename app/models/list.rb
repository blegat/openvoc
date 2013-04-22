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
  attr_accessible :name
  validates :name, presence: true

  belongs_to :owner, class_name: "User"
  validates :owner, presence: true

  has_many :childs, class_name: "List", foreign_key: :parent_id
  belongs_to :parent, class_name: "List"

  #before_save :set_root_if_no_parent

  has_many :words, through: :inclusions
  has_many :inclusions

  validate :parent_of_same_owner

  def parent_of_same_owner
    if not parent.nil? and owner != parent.owner
      errors.add(:list, "owner must be the same as parent's owner")
    end
  end

  def selectable_path
    p = ''
    current = self
    until current.nil?
      p.prepend("/#{link_to current.name, current}")
      current = current.parent
    end
    p
  end
  def path
    p = ''
    current = self
    until current.nil?
      p.prepend("/#{current.name}")
      current = current.parent
    end
    p
  end
  def set_root_if_no_parent
    if self.parent.nil?# and not self.owner.nil?
      self.parent = self.owner.root
    end
  end

end
# == Schema Information
# Schema version: 20130216160939
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
#  index_lists_on_owner_id   (owner_id)
#  index_lists_on_parent_id  (parent_id)
#

