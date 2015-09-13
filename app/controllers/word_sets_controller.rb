class WordSetsController < ApplicationController
  
  def new
  end
  
  def create
    dataToAdd = params[:wordset][:data_to_add].split("\r\n") # FIXME if error maybe here...
    list = List.find_by(id:params[:wordset][:list_id])
    
    dataToAdd.each do |dta|
      newWords = dta.split('=')
      newWords[0] = delete_blanks(newWords[0])
      newWords[1] = delete_blanks(newWords[1])
      
      
      word1 = Word.find_by(content:newWords[0], language_id:list.language1_id)
      word2 = Word.find_by(content:newWords[1], language_id:list.language2_id)
      if !word1
        word1 = Word.new(content:newWords[0], language_id:list.language1_id)
        word1.owner = current_user
        if !word1.save
            flash_errors(word1, false)
            redirect_to edit_list_url(list)
            return
        end
      end
      if !word2
        word2 = Word.new(content:newWords[1], language_id:list.language2_id)
        word2.owner = current_user
        if !word2.save
            flash_errors(word2, false)
            redirect_to edit_list_url(list)
            return
        end
      end
      
      newWordSet = WordSet.new(word1_id: word1.id, word2_id: word2.id, list_id:list.id, 
                            asked_qa:0, success_qa:0, success_ratio_qa:0.0, 
                            asked_aq:0, success_aq:0, success_ratio_aq:0.0)
      newWordSet.user = current_user
      
      common_meanings = word1.common_meanings(word2)
      
      
      if common_meanings.length == 0 #!word1.has_meaning? && !word2.has_meaning?
        newMeaning = Meaning.create()
        [word1, word2].each do |word|
          unless newMeaning.words.include?(word)
            link = newMeaning.links.create(word:word, owner: current_user)
            if !link.save
              flash_errors(link, false)
              redirect_to edit_list_url(list)
              return
            end
          end
        end
        newWordSet.meaning1_id = newMeaning.id
        newWordSet.meaning2_id = newMeaning.id
      
      elsif  common_meanings.length == 1 #TODO what to do?
        common_meanings[0].links.each do |l|
          if l.word.content == word1.content or l.word.content == word2.content
            l.pro += 1
            if !l.save 
              flash_errors(l, false) 
              redirect_to edit_list_url(list)
              return
            end 
          end
        end
                         
        newWordSet.meaning1_id = common_meanings[0].id
        newWordSet.meaning2_id = common_meanings[0].id
      end
      
      
      if !newWordSet.save 
          flash_errors(newWordSet, false) 
          redirect_to edit_list_url(list)
          return
      end                           

    end
      
    redirect_to edit_list_url(list)
      
      #word2 = Word.new(content:newWords[1], language_id:list.language2_id, owner_id:current_user)
      #if word1.save
        #redirect_to root_url
        #else
        #flash_errors(word1, false)
        #end    
  end
  
  def destroy
    list = List.find_by(id:params[:list_id])
    WordSet.find(params[:id]).destroy
    flash[:success] = "WordSet deleted"
    redirect_to edit_list_url(list)
  end
  
  
  private
  
  def delete_blanks(input)
    max_length = input.length
    i=0
    j=input.length - 1
    k=0
    output=""
    
    while (i < max_length && input[i].blank?) do
      i=i+1 
      puts 'he'
    end
    
    while (j >= 0 && input[j].blank?) do
      j=j-1
      puts 'hi'
    end
    
    while k < max_length do
      if k >= i && k <= j
        output = "#{output}#{input[k]}"
      end
      k = k +1
      puts '3'
    end
    
    return output
  end
  
end
