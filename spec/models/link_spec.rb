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

RSpec.describe Link, type: :model do

  let!(:word1) { FactoryGirl.create(:word) }
  let!(:word2) { FactoryGirl.create(:word) }
  before do
    @link = FactoryGirl.build(:link, word1: word1, word2: word2)
  end

  subject { @link }
  it { should respond_to(:word1) }
  it { should respond_to(:word2) }
  it { should be_valid }
  it { expect(word1).to eq @link.word1 }
  it { expect(word2).to eq @link.word2 }

  describe "when there is no word1" do
    before { @link.word1 = nil }
    it { should_not be_valid }
  end
  describe "when there is no word2" do
    before { @link.word2 = nil }
    it { should_not be_valid }
  end
  describe "when there is no word1 nor word2" do
    before do
      @link.word1 = nil
      @link.word2 = nil
    end
    it { should_not be_valid }
  end
  describe "when it is a duplicate" do
    before do
      @link_dup = @link.dup
      @link.save
      #@link_dup.save
    end
    it { expect(@link_dup).not_to be_valid }
  end
  describe "when it is a reverse duplicate" do
    let (:rlink) { FactoryGirl.build(:link, word1: word2, word2: word1) }
    it { expect(rlink).to be_valid }
  end

end
# == Schema Information
# Schema version: 20130822154326
#
# Table name: links
#
#  id         :integer         not null, primary key
#  word1_id   :integer
#  word2_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  owner_id   :integer
#
# Indexes
#
#  index_links_on_word2_id  (word2_id)
#  index_links_on_word1_id  (word1_id)
#

