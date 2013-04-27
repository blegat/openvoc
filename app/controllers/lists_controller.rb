class ListsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists1, only: [:show]
  before_filter :list_exists2, only: [:moving, :move]
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
    @words = @list.words
  end
  def moving
    @moving = true
    @path = @list.path
    @lists = @list.childs
    @words = @list.words
    render :show
  end
  def move
    # if list_id is nil, that means the prompt "/" has been chosen
    if params[:dest][:list_id].blank?
      @list.parent = nil
      @list.save
    else
      @dest = List.find_by_id(params[:dest][:list_id])
      if @dest.nil? or @dest.owner != current_user
        @moving = true
        flash.now[:error] = "Invalid destination"
      else
        @list.parent = @dest
        @list.save
      end
    end
    @path = @list.path
    @lists = @list.childs
    @words = @list.words
    render :show
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
      list.words
    end
  end
end
