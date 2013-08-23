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

describe Inclusion do

  let(:word) { FactoryGirl.create(:word) }
  let(:author) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list) }

  before { @incl = FactoryGirl.build(:inclusion, word: word,
                                     author: author, list: list) }

  subject { @incl }

  it { should be_valid }
  it { should respond_to(:author) }
  it { should respond_to(:word) }
  it { should respond_to(:list) }
  its(:word) { should == word }
  its(:author) { should == author }
  its(:list) { should == list }
  describe "accessible attributes" do
    it "should not allow access to word_id" do
      expect do
        Inclusion.new(word_id: word.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to author_id" do
      expect do
        Inclusion.new(author_id: author.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to list_id" do
      expect do
        Inclusion.new(list_id: list.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when word is not present" do
    before { @incl.word = nil }
    it { should_not be_valid }
  end

  describe "when author is not present" do
    before { @incl.author = nil }
    it { should_not be_valid }
  end

  describe "when list is not present" do
    before { @incl.list = nil }
    it { should_not be_valid }
  end

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

