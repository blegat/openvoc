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

class User < ActiveRecord::Base
  has_many :authentications, dependent: :destroy
  has_one :registration, dependent: :destroy
  validates :email, uniqueness: true
  def self.from_omniauth(auth)
    find_by_provider_and_uid(auth["provider"], auth["uid"]) ||
      create_with_omniauth(auth)
  end
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.email = auth["info"]["email"]
    end
  end

  # registration: registration
  # omniauth: omniauth
  # auth: omniauth or registration

  def apply_omniauth(omniauth)
    self.email = omniauth['info']['email'] if email.blank?
    self.name = omniauth['info']['name'] if name.blank?
    # no save ? :/
    authentications.build(provider: omniauth['provider'],
                          uid: omniauth['uid'])
  end

  def registered?()
    !self.registration.nil?
  end
  def update_email(auth)
    self.email = auth.email
    self.save
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

end
