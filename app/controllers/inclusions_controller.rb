class InclusionsController < ApplicationController
  before_filter :signed_in_user
  def create
    word = Word.find_by_id(params[:word_id])
    if word
      @list = List.find_by_id(params[:inclusion][:list_id])
      if @list and @list.owner == current_user
        hash = Hash.new
        # FIXME remove the first redundant one ?
        #       the second one is more sure so is needed
        if @list.words.find_by_id(word).nil? and
          @list.add_word(word, current_user).nil?
          hash[:success] = "Successfully added"
        else
          hash[:notice] = "#{word.content} is already in #{@list.path}"
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
