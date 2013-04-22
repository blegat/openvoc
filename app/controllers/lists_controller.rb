class ListsController < ApplicationController
  before_filter :signed_in_user
  def new
    @list = List.find_by_id(params[:list_id])
    @path = get_path(@list)
    @lists = get_childs(@list)
    @words = get_childs(@list)
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
    @list = List.find(params[:id])
    @path = @list.path
    @lists = @list.childs
    @words = @list.words
  end
  private
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
