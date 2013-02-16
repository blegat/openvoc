class LinksController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create]

  def new
    if params[:word_id]
      @word = Word.find_by_id(params[:word_id])
      if @word
        render 'words/show'
      end
    end
    #@link.word1 = Word.new(content: "test")
  end
  def find_word(word_content, language_id, n)
    begin
      language = Language.find(language_id)
    rescue ActiveRecord::RecordNotFound
      return nil, nil
      # Language id should be valid
      # Except in case of hacking so no flash is necessary
    end
    begin
      word = language.words.find_by_content!(word_content)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = 'There is no "' + word_content +
        '" in language ' + language.name
      # now because otherwise it stays for the next page load too
      return nil, language
    end
    return word, language
  end
  def create
    @word1 = Word.find_by_id(params[:word_id])
    if @word1

      @word1_content = @word1.content
    else
      @word1_content = params[:link][:word1] # used by links/new.html.erb
      @word1, @language1 = find_word(params[:link][:word1],
                                     params[:link][:language1_id], 1)
    end
    @word2_content = params[:link][:word2]
    @word2, @language2 = find_word(params[:link][:word2],
                                   params[:link][:language2_id], 2)
    if @word1
      if @word2
        link = @word1.links1.build
        link.word2 = @word2
        link.owner = current_user
        if link.save
          flash.now[:success] = "New link from 
          #{view_context.link_to(@word1.content,
                             word_path(@word1))}
          to
                             #{view_context.link_to(@word2.content,
                             word_path(@word2))}
          created".html_safe
          render 'new'
        else
          @word = @word1
          render 'words/show'
        end
      else
        @word = @word1
        render 'words/show'
      end
    else
      render 'new'
    end
  end

  def show
    @link = Link.find(params[:id])
    @word = @link.word1
    render 'words/show'
  end
end
