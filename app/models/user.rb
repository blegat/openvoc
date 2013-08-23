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

  validates :email, presence: true,
    format: { with: Registration::VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :name, presence: true

  has_many :authentications, dependent: :destroy
  has_one :registration, dependent: :destroy
  before_save :create_remember_token

  has_many :words, foreign_key: :owner_id
  has_many :links, foreign_key: :owner_id

  has_many :lists, foreign_key: :owner_id
  has_many :inlusions, foreign_key: :author_id

  has_many :trains, dependent: :destroy

  def root_lists
    self.lists.find_all_by_parent_id(nil)
  end

  def lists_without(word)
    lists.select do |list|
      not list.contain_word(word)
    end
  end
  def lists_outside(list)
    lists = []
    root_lists.each do |cur|
      lists.concat(cur.lists_outside(list))
    end
    lists
  end

  def set_root_if_none
    if self.root.nil?
      self.root = self.lists.create(name: '/')
      self.root
    end
  end

  # registration: registration
  # omniauth: omniauth hash
  # authentication: authentication
  # auth: authentication or registration
  #
  # Email: mandatory, unique
  # Name: mandatory
  # omniauth:
  #   create:
  #     Fill name & email if blank because:
  #      - changes are bad
  #      - first account is the main one
  # registration:
  #   new:
  #     Prefill with full name and email
  #   create:
  #     Fill name & email

  def auth_number
    authentications.count + (registration.nil? ? 0 : 1)
  end

  def self.build_with_omniauth(omniauth)
    User.new(name: omniauth['info']['name'],
             email: omniauth['info']['email'])
  end
  def build_omniauth(omniauth)
    authentications.build(provider: omniauth['provider'],
                          uid: omniauth['uid'])
  end

  def self.build_with_registration(registration)
    User.new(name: registration[:name],
             email: registration[:registration][:email])
  end

  def registered?()
    !self.registration.nil?
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
# Schema version: 20130822154326
#
# Table name: users
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  email          :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  remember_token :string(255)
#
# Indexes
#
#  index_users_on_remember_token  (remember_token)
#  index_users_on_email           (email) UNIQUE
#

