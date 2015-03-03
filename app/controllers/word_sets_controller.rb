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
      
      @word1 = Word.new(content:@newWords[0], language_id:@list.language1_id)
      @word2 = Word.new(content:@newWords[1], language_id:@list.language2_id)
      
      @word1.owner = current_user
      @word2.owner = current_user
      
      if @word1.save
        if @word2.save
          @newWordSet = WordSet.new(word1_id: @word1.id, word2_id: @word2.id, 
          list_id:@list.id, meaning1_id: "1", meaning2_id: "2")
          @newWordSet.user = current_user
          if !@newWordSet.save 
            flash_errors(@newWordSet, false) 
          end                           
        else
          flash_errors(@word2, false)
        end
      else
        flash_errors(@word1, false)
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
