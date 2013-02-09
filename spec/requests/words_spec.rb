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

describe "Words" do
  subject { page }
  let!(:language) { FactoryGirl.create(:language) }
  let!(:word) { FactoryGirl.create(:word, language: language) }
  let!(:other_word1) { FactoryGirl.create(:word) }
  let!(:other_word2) { FactoryGirl.create(:word) }
  describe "new word" do
    before { visit new_language_word_path(language) }
    it { should have_selector "h1", text: language.name }
    it { should have_field "word_content" }
  end

  describe "show page" do
    let!(:l) { FactoryGirl.create(:link, word1: word, word2: other_word1) }
    let!(:rl) { FactoryGirl.create(:link, word1: other_word2, word2: word) }
    before { visit word_path(word) }
    it { should have_selector "h1", text: language.name }
    it { should have_selector "h2", text: word.content }
    describe "words" do
      it { should have_link "New link",
        href: new_word_link_path(word) }
      it { should have_link other_word1.content,
        href: link_path(l) }
      it { should_not have_link other_word2.content,
        href: link_path(rl) }
    end
    #describe "new link" do
      #before do
        #visit new_word_link_path(word)
        #fill_in "Content", with:
      #end
    #end
  end
end
