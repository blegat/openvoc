class Meaning < ActiveRecord::Base
  has_many :links, class_name: "Link", foreign_key: "meaning_id"
  has_many :words, through: :links, source: :word
  
end
