class Meaning < ActiveRecord::Base
  has_many :links, class_name: "Link", foreign_key: "meaning_id"
  has_many :words, through: :links, source: :word
  
  def words_in_two_lang(lang1,lang2)
    words_lang1 = self.words.where(language_id: lang1.id)
    words_lang2 = self.words.where(language_id: lang2.id)
    
    output = ""
    
    if not words_lang1.empty?
      output << "<b>" << lang1.name << "</b>" << ": "
      words_lang1.each do |w|
        output << w.content << ", "
      end
      output = output[0...-2]
      output << "</br>"
    end
    
    if not words_lang2.empty?
      output << "<b>" << lang2.name << "</b>" << ": "
      words_lang2.each do |w|
        output << w.content << ", "
      end
      output = output[0...-2]
    end
    output
  end
  
  def words_in_one_lang(lang)
    words_lang = self.words.where(language_id: lang.id)
    output = ""
    if not words_lang.empty?
      words_lang.each do |w|
        output << w.content << ", "
      end
      output = output[0...-2]
    end
    output
  end
  
  
end
