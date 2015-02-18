class InclusionsController < ApplicationController
  before_filter :signed_in_user
  def create
    word = Word.find_by_id(params[:word_id])
    if word
      @list = List.find_by_id(params[:inclusion][:list_id])
      if @list and @list.owner == current_user
        hash = Hash.new
        if @list.words.find_by_id(word)
          hash[:warning] = "#{word.content} is already in #{@list.path}"
        else
          @list.add_word word, current_user
          hash[:success] = "Successfully added"
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
