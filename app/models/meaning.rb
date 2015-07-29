class Meaning < ActiveRecord::Base
  before_save :default_values
  has_many :links, class_name: "Link", foreign_key: "meaning_id"
  has_many :words, through: :links, source: :word
  
  before_save :default_values
    def default_values
      self.pro ||= 1
      self.contra ||= 9
      self.confidence ||= 0.1
    end
end
