class MeaningsController < ApplicationController
  before_filter :signed_in_user, only: [:create]

  def redirect_appropriately
    @list = List.find_by_id(params[:meaning][:list_id])
    if @list.nil?
      redirect_to new_link_path and return true
    else
      redirect_to edit_list_url(@list) and return true
    end
  end

  def create
    choice = params[:meaning][:action]
    if choice == "donothing"
      redirect_appropriately and return
    end
    @word1 = Word.find_by_id(params[:meaning][:word1_id])
    @word2 = Word.find_by_id(params[:meaning][:word2_id])
    if @word1.nil? or @word2.nil?
      redirect_to root_path and return
    end


    if choice == "new"
      newmeaning = Meaning.create!
    else
      newmeaning = Meaning.find_by(id:eval(params[:meaning][:action]).to_i)
      if newmeaning.nil?
        flash[:error] = "An error occured"
        redirect_to root_path and return
      end
    end
    [@word1, @word2].each do |word|
      unless newmeaning.words.include?(word)
        link = newmeaning.links.create(word:word, owner: current_user)
        if link.save
          flash[:success] = "Meaning updated : TODO"
        else
          flash_errors(link, false)
          break
        end
      end
    end

    theWS = WordSet.find_by(id:params[:meaning][:wordset_id])
    if theWS
      theWS.meaning1_id = newmeaning.id
      theWS.meaning2_id = newmeaning.id
      if not theWS.save
        flash[:error] = "Error while save the WordSet"
      end
    else
    end

    redirect_appropriately and return
  end

  def show
    @meaning = Meaning.find_by_id(params[:id])
    if @meaning.nil?
      redirect_to root_path and return
    end
  end
end
