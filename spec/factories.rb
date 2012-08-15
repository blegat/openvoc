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
end
