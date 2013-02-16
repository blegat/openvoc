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
    language
    association :owner, factory: :user
  end
  factory :link do
    association :word1, factory: :word
    association :word2, factory: :word
    association :owner, factory: :user
  end
end
