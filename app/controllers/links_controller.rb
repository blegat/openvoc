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
      puts language.name
      word = language.words.build(content: word_content)
      word.owner = current_user
      unless word.save
        word = nil
        flash_errors word
      end
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
    @list = List.find_by_id(params[:link][:list_id])
    if @word1
      # Add it to the list
      unless @list.nil?
        if @list.owner != current_user
          redirect_to root_path and return
        end
        if @list.words.find_by_id(@word1).nil?
          @list.add_word(@word1, current_user)
        else
          flash.now[:notice] = "#{@word1.content} is already in #{@list.path}"
        end
      end
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
          if @list.nil?
            render 'new'
          else
            render_list_show
          end
        else
          l = Link.find_by_word1_id_and_word2_id(@word1, @word2)
          if l.nil?
            flash_errors link
            if @list.nil?
              @word = @word1
              render 'words/show'
            else
              render_list_show
            end
          else
            if @list.nil?
              flash.now[:error] = "This link already exists"
              redirect_to l
            else
              # At least it has been added to the list so it wasn't useless
              flash.now[:notice] = "This link already exists"
              render_list_show
            end
          end
        end
      else
        if @list.nil?
          @word = @word1
          render 'words/show'
        else
          render_list_show
        end
      end
    else
      if @list.nil?
        render 'new'
      else
        render_list_show
      end
    end
  end

  def render_list_show
    @path = @list.path
    @lists = @list.childs
    @words = @list.words
    render 'lists/show'
  end

  def show
    @link = Link.find(params[:id])
    @word = @link.word1
    render 'words/show'
  end
end
