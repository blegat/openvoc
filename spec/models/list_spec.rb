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

describe List do

  let(:owner) { FactoryGirl.create(:user) }
  let(:list_same_owner) { FactoryGirl.create(:list, owner: owner) }

  before { @list = FactoryGirl.build(:list, owner: owner,
                                     parent: list_same_owner) }

  subject { @list }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:owner) }
  it { should respond_to(:parent) }
  it { should respond_to(:childs) }
  it { should respond_to(:inclusions) }
  it { should respond_to(:words) }
  its(:owner) { should == owner }
  describe "accessible attributes" do
    it "should not allow access to owner_id" do
      expect do
        List.new(owner_id: owner.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to parent_id" do
      expect do
        List.new(parent_id: list_same_owner.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when name is not present" do
    before { @list.name = nil }
    it { should_not be_valid }
  end

  describe "when owner is not present" do
    before { @list.owner = nil }
    it { should_not be_valid }
  end

  its(:path) { should == "/#{list_same_owner.name}/#{@list.name}" }
  its(:rec_parents) { should include(list_same_owner) }
  describe "when parent belongs to a different owner" do
    let(:list_diff_owner) { FactoryGirl.create(:list) }
    before { @list.parent = list_diff_owner }
    it { should_not be_valid }
  end
  describe "when it has a child" do
    before { @list.save }
    it { list_same_owner.childs.should include(@list) }
  end
  describe "when the parent is destroyed" do
    before do
      @list.save
      list_same_owner.destroy
    end
    it "should destroy all childs" do
      List.find_by_id(@list.id).should be_nil
    end
  end

  describe "when a word is added" do
    let(:word_same_owner) { FactoryGirl.create(:word) }
    let(:word_diff_owner) { FactoryGirl.create(:word) }
    before do
      @list.save
      @list.add_word(word_same_owner, owner)
    end
    its(:words) { should include(word_same_owner) }
    its(:words) { should_not include(word_diff_owner) }
    describe "when a second word is added" do
      before { @list.add_word(word_diff_owner, owner) }
      its(:words) { should include(word_same_owner) }
      its(:words) { should include(word_diff_owner) }
    end
    it "should create an inclusion" do
      expect { @list.add_word(word_diff_owner, owner) }.to change(Inclusion, :count).by 1
    end
    it "should not add a word twice" do
      #expect { @list.add_word(word_same_owner, owner) }.not_to change(Inclusion, :count)
      expect do
        @list.add_word(word_same_owner, owner)
      end.to raise_error("Word has already been taken")
    end
    it "should destroy the inclusion when destroyed" do
      expect do
        @list.destroy
      end.to change(Inclusion, :count).by -1
    end
    it "should not destroy the word when destroyed" do
      expect do
        @list.destroy
      end.not_to change(Word, :count)
    end
  end

end
# == Schema Information
# Schema version: 20130822154326
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
#  index_lists_on_parent_id  (parent_id)
#  index_lists_on_owner_id   (owner_id)
#

