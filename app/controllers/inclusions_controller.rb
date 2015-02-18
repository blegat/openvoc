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

  private

  # Require that :user be a key in the params Hash,
  # and only accept :first, :last, and :email attributes
  # We use params.require(:episode) instead of params[:episode] to ensure that the parameters hash is available and to avoid a nil exception if they are not.
  def user_params
    params.require(:inclusion).permit(:list_id)
  end
end
