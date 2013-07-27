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

FactoryGirl.define do
  factory :user do
    sequence(:name) do |n|
      alphabet = ('a'..'z').to_a
      ret = ""
      # first value of n is 1
      while n != 0 do
        ret += alphabet[n % 26]
        n /= 26
      end
      ret
    end
    sequence(:email) do |n|
      alphabet = ('a'..'z').to_a
      ret = ""
      # first value of n is 1
      while n != 0 do
        ret += alphabet[n % 26]
        n /= 26
      end
      "#{ret}@openvoc.com"
    end
  end
  factory :language do
    sequence(:name) do |n|
      alphabet = ('a'..'z').to_a
      ret = ""
      # first value of n is 1
      while n != 0 do
        ret += alphabet[n % 26]
        n /= 26
      end
      ret.capitalize
    end
  end
  factory :word do
    #   sequence(:content) do |n|
    #     alphabet = ('a'..'z').to_a
    #     if n == 0 then
    #       "a"
    #     else
    #       c = ""
    #       while n != 0 do
    #         c += alphabet[n % 26]
    #         n /= 26
    #       end
    #       print c
    #       c
    #     end
    #   end
    content "a"
    #language
    association :language, factory: :language
    association :owner, factory: :user
  end
  factory :link do
    association :word1, factory: :word
    association :word2, factory: :word
    association :owner, factory: :user
  end
  factory :train do
    guess "42"
    success true
    association :user
    association :word
  end
  factory :list do
    sequence(:name) do |n|
      "a#{n}"
    end
    #association :parent, factory: :list, { nil }
    parent nil
    association :owner, factory: :user
  end
  factory :inclusion do
    association :author, factory: :user
    association :list
    association :word
  end
end
