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

RSpec.describe "Languages", type: :request do
  subject { page }
  # without '!', let is lazy, it does not do its job until
  # language is used
  let!(:language) { FactoryGirl.create(:language) }
  describe "index page" do
    before do
      visit languages_path
    end
    # FIXME: path or url ?
    it { should have_selector "h1", text: "Languages" }
    it { should have_link language.name, href: language_path(language)  }
  end

  describe "show page" do
    let!(:w1) { FactoryGirl.create(:word, language: language, content: 'a') }
    let!(:w2) { FactoryGirl.create(:word, language: language, content: 'b') }
    before { visit language_path(language) }
    it { should have_selector "h1", text: language.name }
    describe "words" do
      it { should have_link "New word",
        href: new_language_word_path(language) }
      it { should have_link w1.content,
        href: word_path(w1) }
      it { should have_link w2.content,
        href: word_path(w2) }
      it { should have_content(language.words.count) }
    end
  end
end
