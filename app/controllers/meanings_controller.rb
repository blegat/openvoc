class MeaningsController < ApplicationController
  before_filter :signed_in_user, only: [:create]

  def redirect_appropriately
    @list = List.find_by_id(params[:meaning][:list_id])
    if @list.nil?
      redirect_to new_link_path and return true
    else
      redirect_to @list and return true
    end
  end

  def create
    choice = params[:meaning][:meaning]
    if choice == "donothing"
      redirect_appropriately and return
    end
    @word1 = Word.find_by_id(params[:meaning][:word1_id])
    @word2 = Word.find_by_id(params[:meaning][:word2_id])
    if @word1.nil? or @word2.nil?
      redirect_to root_path and return
    end

    if choice == "new"
      meaning = Meaning.create!
    else
      meaning.find_by_id(params[:meaning][:meaning].to_i)
      if meaning.nil?
        redirect_to root_path and return
      end
    end
    [@word1, @word2].each do |word|
      unless meaning.words.include?(word)
        link = meaning.links.create(word:word, owner: current_user)
        if link.save
          flash[:success] = "New link from
          #{view_context.link_to(word.content,
          word_path(word))}
          to
          #{view_context.link_to(meaning.id,
          meaning_path(meaning))}
          created".html_safe
        else
          flash_errors(link, false)
          break
        end
      end
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
