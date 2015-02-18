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

class Language < ActiveRecord::Base
  #attr_accessible :name
  VALID_LANGUAGE_REGEX = /\A[[:upper:]][[:lower:]]*\z/
  validates :name, presence: true, length: { maximum: 32 },
    format: { with: VALID_LANGUAGE_REGEX },
    uniqueness: { case_sensitive: false }

  has_many :words, dependent: :destroy
end
# == Schema Information
# Schema version: 20130822154326
#
# Table name: languages
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
# Indexes
#
#  index_languages_on_name  (name) UNIQUE
#

