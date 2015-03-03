class ListsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists1, only: [:show, :edit]
  before_filter :list_exists2, only: [:moving, :move, :export]
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
    @path = @list.path
    @lists = @list.childs
    @words = get_words(@list)
    @wordsets = get_wordsets(@list)
    @language1_name = Language.find_by(id:@list.language1_id).name
    @language2_name = Language.find_by(id:@list.language2_id).name    
  end
  
  def edit
    @path = @list.path
    @wordsets = get_wordsets(@list)
    @language1_name = Language.find_by(id:@list.language1_id).name
    @language2_name = Language.find_by(id:@list.language2_id).name
    @languages = Language.all    
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
        flash.now[:danger] = "Invalid destination"
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
  def training
    list = List.find_by_id(params[:list_id])
    max = params[:train][:max]
    rec = params[:train][:rec]
    if max.nil? or rec.nil? or list.nil?
      redirect_to root_path and return
    end
    max = max.to_i
    rec = rec.to_i
    if rec != 0 and rec != 1
      redirect_to root_path and return
    end
    if max < 0 or max > 100
      redirect_to list, flash: { danger: 'Maximum success rate should be between 0 and 100' } and return
    end
    redirect_to new_list_train_path(list, rec: rec, max: max)
  end
  private
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
  def get_wordsets(list)
    if list.nil?
      nil
    else
      list.wordsets#.paginate(page: params[:page])
    end
  end
end
