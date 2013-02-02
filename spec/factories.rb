FactoryGirl.define do
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
  end
end
