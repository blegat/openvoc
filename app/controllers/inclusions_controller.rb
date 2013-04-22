class InclusionsController < ApplicationController
  before_filter :signed_in_user
  def create
    word = Word.find_by_id(params[:word_id])
    if word
      @list = List.find_by_id(params[:inclusion][:list_id])
      if @list and @list.owner == current_user
        hash = Hash.new
        if @list.words.find_by_id(word)
          hash[:notice] = "It was already there"
        else
          hash[:success] = "Successfully added"
          @list.words << word
        end
        redirect_to @list, flash: hash
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
