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

describe Language do

  before { @language = FactoryGirl.build(:language, name: "English") }

  subject { @language }

  it { should respond_to(:name) }
  it { should respond_to(:words) }

  it { should be_valid }

  describe "when name is not present" do
    before { @language.name = nil }
    it { should_not be_valid }
  end
  describe "when name is blank" do
    before { @language.name = " " }
    it { should_not be_valid }
  end
  describe "when name is too long" do
    before { @language.name = "A" + "a" * 32 }
    it { should_not be_valid }
  end

  describe "when name isn't capitalized" do
    before { @language.name = "english" }
    it { should_not be_valid }
  end

  describe "when name has non-letter characters" do
    before { @language.name = "Ab0c" }
    it { should_not be_valid }
  end

  describe "when name is already taken" do
    before do
      language_with_same_name = @language.dup
      language_with_same_name.save
    end

    it { should_not be_valid }
  end

  describe "when it has a words" do
    before do
      @language.save
    end
    let!(:word) { FactoryGirl.create(:word, language: @language) }
    subject { word }
    it { @language.words.should include(word) }
    it "should destroy the word when the language is destroyed" do
      expect { @language.destroy }.to change(Word, :count).by -1
    end
  end
end
# == Schema Information
# Schema version: 20130317152821
#
# Table name: languages
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
# Indexes
#
#  index_languages_on_name  (name) UNIQUE
#

