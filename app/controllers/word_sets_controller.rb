class WordSetsController < ApplicationController

  def new
  end

  def create
    dataToAdd = params[:wordset][:data_to_add]
    from_edit_list_url = false
    hash = Hash.new
    if dataToAdd
      from_edit_list_url = true
      dataToAdd = dataToAdd.split("\r\n") # FIXME if error maybe here...
      # Added from the list
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
          meaning = newMeaning
        elsif  common_meanings.length == 1 #TODO what to do?
          common_meanings[0].links.each do |l|
            if l.word.content == word1.content or l.word.content == word2.content
              l.pro += 1
              if !l.save
                flash_errors(l, false)
                redirect_to edit_list_url(list) and return
                return
              end
            end
          end
          meaning = common_meanings[0]
        end

        if list.wordsets.where(word_id: word1.id).any?
          # we cannot have twice the same word, even with different meaning
          hash[:warning] = "#{word1.content} is already in #{list.path}"
          redirect_to edit_list_url(list), flash: hash and return # FIXME Stops here and do not look at other words, problem ?
        else
          h = list.add_word word1, meaning, current_user
          unless h.nil?
            hash[:danger] = h
            redirect_to edit_list_url(list), flash: hash and return # FIXME Stops here and do not look at other words, problem ?
          end
        end
      end
      hash[:success] = "Successfully added"
      redirect_to edit_list_url(list), flash: hash
      
      
    else
      word = Word.find_by_id(params[:word_id])
      meaning = Meaning.find_by_id(params[:meaning_id])
      if word and meaning
        list = List.find_by_id(params[:wordset][:list_id])
        # FIXME check good language ? Or language1, language2 is just for automatic word creation ?
      else
        redirect_to root_path
      end

      if list and list.can_edit(current_user)
        if list.wordsets.where(word_id: word.id).any?
          # we cannot have twice the same word, even with different meaning
          hash[:warning] = "#{word.content} is already in #{list.path}"
        else
          h = list.add_word word, meaning, current_user
          if h.nil?
            hash[:success] = "Successfully added"
          else
            hash[:danger] = h
          end
        end
        redirect_to list, flash: hash
      else
        redirect_to root_path
      end
    end



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
    end

    while (j >= 0 && input[j].blank?) do
      j=j-1
    end

    while k < max_length do
      if k >= i && k <= j
        output = "#{output}#{input[k]}"
      end
      k = k +1
    end

    return output
  end

end
