require 'tempfile'
require'roo'

class ListsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists1, only: [:show]
  before_filter :list_exists2,
    only: [:moving, :move, :export, :importing, :preview_import, :import, :training]
  before_filter :list_owner,
    only: [:moving, :move, :importing, :preview_import]
  def new
    @list = List.find_by_id(params[:list_id])
    # if list is nil, it is '/'
    @path = get_path(@list)
    @lists = get_childs(@list)
    @words = get_words(@list)
    @new_list = current_user.lists.build
    #@new_list.parent = @list # yet useless
    render :show
  end
  def create
    @list = List.find_by_id(params[:list_id])
    @new_list = current_user.lists.build(name: params[:list][:name])
    if @list
      @new_list.parent = @list
    end
    if @new_list.save
      flash.now[:success] = "#{@new_list.name} successfully created"
      redirect_to @new_list
    else
      flash_errors(@new_list)
      @path = get_path(@list)
      @lists = get_childs(@list)
      @words = get_words(@list)
      render :show
    end
  end
  def index
    @path = '/'
    @lists = current_user.root_lists
    render :show
  end
  def show
    #raise flash[:error].to_s
    @path = @list.path
    @lists = @list.childs
    @words = get_words(@list)
  end
  def moving
    @moving = true
    @path = @list.path
    @lists = @list.childs
    @words = get_words(@list)
    render :show
  end
  def move
    # if list_id is nil, that means the prompt "/" has been chosen
    if params[:dest][:list_id].blank?
      @list.parent = nil
      @list.save
    else
      @dest = List.find_by_id(params[:dest][:list_id])
      if @dest.nil? or @dest.owner != current_user or
        @dest == @list or @dest.in?(@list.rec_parents)
        @moving = true
        flash.now[:error] = "Invalid destination"
      else
        @list.parent = @dest
        @list.save
      end
    end
    @path = @list.path
    @lists = @list.childs
    @words = get_words(@list)
    render :show
  end
  def export
    content = @list.words.inject("") do |sum, word|
      "#{sum}#{word.content}|#{word.translations.inject("") do |s, w|
        if s.blank?
          "#{w.content}"
        else
          "#{s},#{w.content}"
        end
      end}\n"
    end
    send_data content, filename: 'export.txt'
  end
  def importing
    @importing = true
    @path = @list.path
    @lists = @list.childs
    @words = get_words(@list)
    render :show
  end
  def preview_import
    if params[:file].nil?
      redirect_to root_path and return
    end
    @language1 = Language.find_by_id(params[:file][:language1_id])
    @language2 = Language.find_by_id(params[:file][:language2_id])
    if @language1.nil? or @language2.nil? or (not ["1","2"].include? params[:file][:column1])
      redirect_to root_path and return
    end
    format = params[:file][:format]
    if params[:file][:file].nil?
      redirect_to @list, flash: { error: "Missing file" } and return
    end
    file = params[:file][:file]
    ext = File.extname(file.original_filename)
    if ext != format
      if ext == ''
        actual = "has no extension"
      else
        actual = "is '#{ext}'"
      end
      flash[:notice] =
        "You said the file extension was '#{format}' but it actually #{actual}. If the file extension was correct on your computer, you have told us the wrong one and the following output might be absurd. For your curiousity the corresponding MIME type you claimed was '#{ext_to_mime[format]}' but according to its extension, the MIME type of the file you gave us is '#{file.content_type}'."
    end
    split1 = params[:file][:split1] # I'm not stripping it, It could be just a space !
    split2 = params[:file][:split2]
    if split1.nil? or split2.nil?
      redirect to root_path and return
    end
    split1 = split1 if !split1.empty? # If "", it becomes nil ("a,b".split(nil) returns ["a,b"])
    split2 = split2 if !split2.empty?

    # with "Tempfile.open do |f| .. end", I'm not sure that what is returned
    # makes sense (I've read the source from the doc)
    f = Tempfile.open(['import',format], Rails.root.join('tmp'))
    begin
      f.binmode
      f.print(file.read)
      f.flush
    ensure
      f.close
    end

    begin
      case format
      when ".ods"
        @spreadsheet = Roo::OpenOffice.new(f.path)
      when ".csv"
        @spreadsheet = Roo::CSV.new(f.path)
      when ".xls"
        @spreadsheet = Roo::Excel.new(f.path)
      when ".xlsx"
        @spreadsheet = Roo::Excelx.new(f.path)
      else
        redirect_to root_path and return
      end
    rescue TypeError
      redirect_to list_path(@list), flash: { error: "The file is not a valid '#{format}' file" }
    end
    if @spreadsheet.sheets.count > 1
      flash[:notice] = "There is more than one sheet, I will only use the first one."
      @spreadsheet.default_sheet = @spreadsheet.sheets.first
    end
    if @spreadsheet.last_column < 2
      redirect_to list_path @list, flash:
        { error: "I need at least 2 columns" }
    end
    @spreadsheet.parse(clean: true)

    @words1_to_create = Array.new
    @words2_to_create = Array.new
    @links1_to_create = Array.new
    @links2_to_create = Array.new
    @words_to_add = Array.new
    column1 = params[:file][:column1].to_i
    column2 = (column1 % 2) + 1
    for row in (@spreadsheet.first_row)..(@spreadsheet.last_row)
      @spreadsheet.cell(row, column1).split(split1).each do |content1|
        @spreadsheet.cell(row, column2).split(split2).each do |content2|
          content1.strip! # removes blank at beginning and end
          content2.strip!
          word1 = @language1.words.find_by_content(content1)
          word2 = @language2.words.find_by_content(content2)
          if word1.nil? and not content1.blank?
            @words1_to_create << content1
          end
          if word2.nil? and not content2.blank?
            @words2_to_create << content2
          end
          if not content1.blank? and not content2.blank? and
            (((not word1.nil?) and (not word2.nil?) and
              (not word1.translations.include? word2)) or (word1.nil?) or (word2.nil?))
            # Can't pass 2D array by POST to #import so use 2 arrays
            @links1_to_create << content1
            @links2_to_create << content2
          end
          if not content1.blank? and @list.words.find_by_content(content1).nil?
            @words_to_add << content1
          end
        end
      end
    end

    @path = @list.path
  end
  def import
    # We can trust session
    #language1 = Language.find(session[:language1])
    #words1_to_create = session[:words1_to_create]
    #language2 = Language.find(session[:language2])
    #words2_to_create = session[:words2_to_create]
    #links_to_create = session[:links_to_create]
    #words_to_add = session[:words_to_add]

    language1 = Language.find(params[:import][:language1])
    words1_to_create = params[:import][:words1_to_create] || []
    language2 = Language.find(params[:import][:language2])
    words2_to_create = params[:import][:words2_to_create] || []

    links1_to_create = params[:import][:links1_to_create] || []
    links2_to_create = params[:import][:links2_to_create] || []
    if links1_to_create.count != links2_to_create.count
      redirect_to root_path and return
    end
    links_to_create = links1_to_create.zip(links2_to_create)

    words_to_add = params[:import][:words_to_add]

    # warn if created/deleted between preview and now
    warnings = Array.new
    errors = Array.new
    unless words1_to_create.nil?
      for word_content in words1_to_create
        word = language1.words.build(content: word_content)
        word.owner = current_user
        unless word.save
          warnings << "Word '#{word_content}' could not be created. #{word.errors.full_messages.to_sentence}"
        end
      end
    end

    unless words2_to_create.nil?
      for word_content in words2_to_create
        new = language2.words.build(content: word_content)
        new.owner = current_user
        new.save
        unless word.save
          warnings << "Word '#{word_content}' could not be created. #{word.errors.full_messages.to_sentence}"
        end
      end
    end

    unless links_to_create.nil?
      for link in links_to_create
        word1 = Word.find_by_content(link[0])
        if word1.nil?
          errors << "Link between #{link[0]} and '#{link[1]}' could not be added to the list. #{link[0]} has been deleted between by someone else the preview and the import."
        else
          word2 = Word.find_by_content(link[1])
          if word2.nil?
            errors << "Link between #{link[0]} and '#{link[1]}' could not be added to the list. #{link[1]} has been deleted between by someone else the preview and the import."
          else
            new_link = word1.links1.build
            new_link.word2 = word2
            new_link.owner = current_user
            unless new_link.save
              warnings << "Link between '#{link[0]}' and '#{link[1]}' could not be created. #{new_link.errors.full_messages.to_sentence}"
            end
          end
        end
      end
    end

    unless words_to_add.nil?
      for word_content in words_to_add
        word = Word.find_by_content(word_content)
        if word.nil?
          errors << "Word '#{word_content}' could not be added to the list. It has been deleted between by someone else the preview and the import."
        else
          err = @list.add_word word, current_user
          unless err.nil?
            errors << "Word '#{word_content}' is already in the list. It has been added between by someone else the preview and the import."
          end
        end
      end
    end

    flash[:notice] = warnings.to_sentence
    flash[:error] = errors.to_sentence
    redirect_to @list
  end
  def training
    max = params[:train][:max]
    rec = params[:train][:rec]
    if max.nil? or rec.nil? or @list.nil?
      redirect_to root_path and return
    end
    max = max.to_i
    rec = rec.to_i
    if rec != 0 and rec != 1
      redirect_to root_path and return
    end
    if max < 0 or max > 100
      redirect_to @list, flash: { error: 'Maximum success rate should be between 0 and 100' } and return
    end
    redirect_to new_list_train_path(@list, rec: rec, max: max)
  end
  private
  def list_owner
    if @list.owner != current_user
      redirect_to root_path
    end
  end
  def list_exists1
    @list = List.find_by_id(params[:id])
    if @list.nil?
      redirect_to root_path
    end
  end
  def list_exists2
    @list = List.find_by_id(params[:list_id])
    if @list.nil?
      redirect_to root_path
    end
  end
  def get_path(list)
    if list.nil?
      '/'
    else
      list.path
    end
  end
  def get_childs(list)
    if list.nil?
      current_user.root_lists
    else
      list.childs
    end
  end
  def get_words(list)
    if list.nil?
      nil
    else
      list.words.order(:content).paginate(page: params[:page])
    end
  end
end
