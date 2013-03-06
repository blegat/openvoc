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

class Authentication < ActiveRecord::Base
  belongs_to :user
  has_one :email_dest, class_name: User, foreign_key: :email_src_id
  has_one :name_dest, class_name: User, foreign_key: :name_src_id
  attr_accessible :provider, :uid, :user_id

  def provider_name #useless ?
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end

end
# == Schema Information
# Schema version: 20130216160939
#
# Table name: authentications
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  provider   :string(255)
#  uid        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

