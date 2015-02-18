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

require 'rails_helper'

RSpec.describe Word, type: :model do

  let (:language) { FactoryGirl.create(:language) }
  let (:owner) { FactoryGirl.create(:user) }
  before do
    @word = FactoryGirl.build(:word, language: language,
                              owner: owner)
  end

  subject { @word }

  it { should be_valid }
  it { should respond_to(:content) }
  it { should respond_to(:language) }
  it { should respond_to(:owner) }
  it { should respond_to(:trains) }
  it { should respond_to(:inclusions) }
  it { should respond_to(:lists) }
  it { should respond_to(:links1) }
  it { should respond_to(:translations) }
  it { should respond_to(:links2) }
  its(:language) { should == language }
  its(:owner) { should == owner }

  describe "when content is not present" do
    before { @word.content = nil }
    it { should_not be_valid }
  end
  describe "when content is blank" do
    before { @word.content = " " }
    it { should_not be_valid }
  end
  describe "when content is too long" do
    before { @word.content = "A" + "a" * 64 }
    it { should_not be_valid }
  end

  describe "when content has non-alnum characters" do
    before { @word.content = "a|b" }
    it { should be_valid }
  end
  describe "when content has digits" do
    before { @word.content = "a0b" }
    it { should be_valid }
  end
  #describe "when content has accents characters" do
  #  before { @word.content = "åbæéà" }
  #  it { should be_valid }
  #end # FIXME
  describe "when it belongs to no language" do
    before do
      @word.language = nil
    end
    subject { @word }
    it { should_not be_valid }
  end

  describe "when it belongs to nobody" do
    before { @word.owner = nil }
    subject { @word }
    it { should_not be_valid }
  end

  describe "linking" do
    let!(:other_word) { FactoryGirl.create(:word) }
    before { @word.save }
    let!(:link) { FactoryGirl.create(:link,
                                     word1: @word,
                                     word2: other_word) }
    it "should have a link" do
      expect(@word.links1).to include(link)
    end
    it "should have a reverse link" do
      expect(other_word.links2).to include(link)
    end
    it "should have a valid other end" do
      expect(@word.links1.find_by_id(link.id).word2).to eq other_word
    end
    it "should have a valid other end" do
      expect(other_word.links2.find_by_id(link.id).word1).to eq @word
    end
    it "should be in translations" do
      expect(@word.translations).to include(other_word)
    end
    describe "when the word is destroyed" do
      before { @word.destroy }
      it "should destroy all links" do
        expect(Link.find_by_id(link.id)).to be_nil
        # find raise an exceptions so find_by_id is better
      end
      it "should destroy the link of word1" do
        expect(@word.links1).not_to include(link)
      end
      it "should destroy the link of word2" do
        expect(other_word.links2).not_to include(link)
      end
    end
  end

end
# == Schema Information
# Schema version: 20130822154326
#
# Table name: words
#
#  id          :integer         not null, primary key
#  content     :string(255)
#  language_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  link_id     :integer
#  owner_id    :integer
#
# Indexes
#
#  index_words_on_language_id  (language_id)
#  index_words_on_content      (content)
#

