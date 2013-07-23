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

require 'spec_helper'

describe Train do

  let(:word) { FactoryGirl.create(:word) }
  let(:user) { FactoryGirl.create(:user) }

  before { @train = FactoryGirl.build(:train, word: word, user: user) }

  subject { @train }

  it { should be_valid }
  it { should respond_to(:user) }
  it { should respond_to(:word) }
  it { should respond_to(:guess) }
  it { should respond_to(:success) }
  its(:word) { should == word }
  its(:user) { should == user }
  describe "accessible attributes" do
    it "should not allow access to word_id" do
      expect do
        Train.new(guess:"test", word_id: word.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to user_id" do
      expect do
        Train.new(guess:"test", user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when word is not present" do
    before { @train.word = nil }
    it { should_not be_valid }
  end

  describe "when user is not present" do
    before { @train.user = nil }
    it { should_not be_valid }
  end

end
# == Schema Information
#
# Table name: trains
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  word_id    :integer
#  guess      :string(255)
#  success    :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

