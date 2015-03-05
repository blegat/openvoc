class WordSetsController < ApplicationController
  
  
  def new
  end
  
  
  
  def create
    @dataToAdd = params[:wordset][:data_to_add].split("\n")
    @list = List.find_by(id:params[:wordset][:list_id])

    
    
    @dataToAdd.each do |dta|
      @newWords = dta.split('=')
      
      @language1 = Language.find(@list.language1_id)
      @language1 = Language.find(@list.language2_id)
      
      @word1 = Word.find_by(content:@newWords[0], language_id:@list.language1_id)
      @word2 = Word.find_by(content:@newWords[1], language_id:@list.language2_id)
      if !@word1
        @word1 = Word.new(content:@newWords[0], language_id:@list.language1_id)
        @word1.owner = current_user
        if !@word1.save
            flash_errors(@word1, false)
            redirect_to edit_list_url(@list)
            return
        end
      end
      if !@word2
        @word2 = Word.new(content:@newWords[1], language_id:@list.language2_id)
        @word2.owner = current_user
        if !@word2.save
            flash_errors(@word2, false)
            redirect_to edit_list_url(@list)
            return
        end
      end
      
      @newWordSet = WordSet.new(word1_id: @word1.id, word2_id: @word2.id, list_id:@list.id)
      @newWordSet.user = current_user
      
      @common_meanings = @word1.common_meanings(@word2)
      
      if !@word1.has_meaning? && !@word2.has_meaning?
        @newMeaning = Meaning.create()
        [@word1, @word2].each do |word|
          unless @newMeaning.words.include?(word)
            @link = @newMeaning.links.create(word:word, owner: current_user)
            if !@link.save
              flash_errors(@link, false)
              redirect_to edit_list_url(@list)
              return
            end
          end
        end
        @newWordSet.meaning1_id = @newMeaning.id
        @newWordSet.meaning2_id = @newMeaning.id
      
      elsif  @common_meanings.length==1
        @newWordSet.meaning1_id = @common_meanings[0].id
        @newWordSet.meaning2_id = @common_meanings[0].id
      end
      
      

      
      
      
      if !@newWordSet.save 
          flash_errors(@newWordSet, false) 
          redirect_to edit_list_url(@list)
          return
      end                           


    end
      
    
    redirect_to edit_list_url(@list)
      
      #@word2 = Word.new(content:@newWords[1], language_id:@list.language2_id, owner_id:current_user)
      #if @word1.save
        #redirect_to root_url
        #else
        #flash_errors(@word1, false)
        #end    
  end
  
  
  def show
  end
end
