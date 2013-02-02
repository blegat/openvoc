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

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_languages
    make_words
  end
end

def make_languages
  Language.create!(name: "Latin")
  Language.create!(name: "Random")
end

def make_words
  latin = Language.find_by_name("Latin")
  latin_words = []
  content = "est"
  99.times do |n|
    while latin_words.include?(content) do
      content = Faker::Lorem.sentence.split(' ')[0].downcase
    end
    latin.words.create!(content: content)
    latin_words.push(content)
  end
  random = Language.find_by_name("Random")
  random_words = []
  99.times do |n|
    while random_words.include?(content) do
      content = Faker::Lorem.characters(5)
    end
    random.words.create!(content: content)
    random_words.push(content)
  end
end
