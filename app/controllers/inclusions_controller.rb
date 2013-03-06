class InclusionsController < ApplicationController
  before_filter :signed_in_user
  def create
    word = Word.find_by_id(params[:word_id])
    if word
      @list = List.find_by_id(params[:inclusion][:list_id])
      if @list
        if @list.words.find_by_id(word)
          flash.now[:notice] = "Already there"
        else
          flash.now[:success] = "Successfully added"
          @list.words.create(word.id)
        end
        render @list
      else
        @word = word
        render @word
      end
    else
      redirect_to root_path
    end
    #redirect_to root_path
  end
end
