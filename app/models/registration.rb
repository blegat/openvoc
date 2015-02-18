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

class Registration < ActiveRecord::Base
  attr_accessor :skip_user_validation
  #attr_accessible :email, :password, :password_confirmation
  has_secure_password
  belongs_to :user
  validates :user_id, presence: true, unless: :skip_user_validation?
  before_save { self.email.downcase! }
  # VALID_EMAIL_REGEX is also used by User
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, :if => :validate_password?
  # presence: true <- commented to avoid duplication of error message with digest
  validates :password_confirmation, presence: true, :if => :validate_password?
  def validate_password?
    password.present? || password_confirmation.present?
  end

  private

  def skip_user_validation?
    skip_user_validation
  end
end
# == Schema Information
# Schema version: 20130822154326
#
# Table name: registrations
#
#  id              :integer         not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  user_id         :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

