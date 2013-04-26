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
  attr_accessible :name, :email

  belongs_to :email_src, class_name: Authentication
  belongs_to :name_src, class_name: Authentication
  validates :email, uniqueness: true
  # 2 empty emails are not unique...
  validates :name, presence: true

  has_many :authentications, dependent: :destroy
  has_one :registration, dependent: :destroy
  before_save :create_remember_token

  has_many :words, foreign_key: :owner_id
  has_many :links, foreign_key: :owner_id

  has_many :lists, foreign_key: :owner_id
  has_many :inlusions, foreign_key: :author_id

  has_many :trains, dependent: :destroy

  # registration: registration
  # omniauth: omniauth hash
  # authentication: authentication
  # auth: authentication or registration

  def auth_number
    authentications.count + (registration.nil? ? 0 : 1)
  end

  def root_lists
    self.lists.find_all_by_parent_id(nil)
  end

  def lists_without(word)
    lists.select do |list|
      not list.contain_word(word)
    end
  end

  def set_root_if_none
    if self.root.nil?
      self.root = self.lists.create(name: '/')
      self.root
    end
  end

  def self.create_with_omniauth(omniauth)
    User.new(name: omniauth['info']['name'],
             email: omniauth['info']['email'])
  end
  def set_src(authentication)
    email_src = authentication
    name_src = authentication
    save
  end
  def apply_omniauth(omniauth)
    #update_omniauth(omniauth)
    authentications.build(provider: omniauth['provider'],
                          uid: omniauth['uid'])
  end
  def update_with_omniauth(omniauth, authentication)
    if self.email.blank? and omniauth['info']['email']
      self.email_src = authentication
    end
    if self.email_src == authentication and omniauth['info']['email']
      self.email = omniauth['info']['email']
    end
    if self.name.blank? and omniauth['info']['name']
      self.name_src = authentication
    end
    if self.name_src == authentication
      self.name = omniauth['info']['name']
    end
    self.save
  end
  def update_omniauth(auth)
    if self.email.blank? and omniauth['info']['email']
      self.email_uid = omniauth['uid']
    end
    if self.email_uid == omniauth['uid']
      self.email = omniauth['info']['email']
    end
    if self.name.blank? and omniauth['info']['name']
      self.name_uid = omniauth['uid']
    end
    if self.name_uid == omniauth['uid']
      self.name = omniauth['info']['name']
    end
    self.save
  end

  def registered?()
    !self.registration.nil?
  end
  def update_email(email)
    if email != self.email
      self.email = email
      if registered?
        self.registration.update_email(email)
      end
      self.save
    end
  end
  def update_email_src(authentication)
    if self.email_src != authentication
      self.email_src = authentication
      self.save
    end
  end
  def update_name(name)
    self.name = name
    self.save
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  private
  def create_remember_token
    # if I create one when there is already one
    # the cookie won't be valid anymore
    if self.remember_token.nil?
      self.remember_token = SecureRandom.urlsafe_base64
    end
  end
end
# == Schema Information
# Schema version: 20130216160939
#
# Table name: users
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  email          :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  name_src_id    :integer
#  email_src_id   :integer
#  remember_token :string(255)
#
# Indexes
#
#  index_users_on_remember_token  (remember_token)
#  index_users_on_email           (email) UNIQUE
#

