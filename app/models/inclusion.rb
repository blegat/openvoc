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
# Schema version: 20130822154326
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

