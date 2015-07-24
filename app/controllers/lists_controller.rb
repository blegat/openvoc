class ListsController < ApplicationController
  before_filter :signed_in_user
  before_filter :get_list, only: [:show, :edit, :destroy]
  before_filter :get_list2, only: [:create, :new, :moving, :move, :export]
  before_filter :get_data_show, only: [:new, :show, :move, :moving]
  def new
    @new_list = current_user.lists.build
    if @list
      @lang1 = Language.find(@list.language1_id)
      @lang2 = Language.find(@list.language2_id)
    end
    render :show
  end
  def create
    @new_list = current_user.lists.build(name: params[:list][:name])
    @new_list.language1_id = params["language1_id"].to_i
    @new_list.language2_id = params["language2_id"].to_i
    if @list
      @new_list.parent = @list
    end
    if @new_list.save
      flash.now[:success] = "#{@new_list.name} successfully created"
      redirect_to @new_list
    else
      flash_errors(@new_list)
      @path = get_path(@list)
      @childs = get_childs(@list)
      @words = get_words(@list)
      render :show
    end
  end
  def index
    @path = '/'
    @childs = current_user.root_lists
    render :show
  end
  def show
    @language1_name = Language.find_by_id(@list.language1_id).name
    @language2_name = Language.find_by_id(@list.language2_id).name    
    @trains = Train.where(list_id:@list.id).paginate(page: params[:page_trains], per_page: 5)
  end
  def destroy
    get_all_childs(@list).each do |ch|
      ch.wordsets.each do |ws|
        ws.destroy
      end
      ch.destroy
    end
    
    @list.wordsets.each do |ws|
      ws.destroy
    end    
    @list.destroy
    
    redirect_to lists_path, 
        flash: { success: "List deleted" } and return
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
    render :show
  end
  def import
      post = DataFile.save(params[:upload])
      render :text => "File has been uploaded successfully"
  end
  def export
    content = "" 
    @list.wordsets.each do |ws|
      word1 = Word.find_by_id(ws.word1_id)
      word2 = Word.find_by_id(ws.word2_id)
      content = content + word1.content + ", "+ word2.content + "\n"
    end    
    if false
      content = @list.words.inject("") do |sum, word|
        "#{sum}#{word.content}|#{word.translations.inject("") do |s, w|
          if s.blank?
            "#{w.content}"
          else
            "#{s},#{w.content}"
          end
        end}\n"
      end
    end
    send_data content, filename: @list.name + '.txt' # TODO no safe
  end
  
  # def training
  #   list = List.find_by_id(params[:list_id])
  #   max = params[:train][:max]
  #   rec = params[:train][:rec]
  #   if max.nil? or rec.nil? or list.nil?
  #     redirect_to root_path and return
  #   end
  #   max = max.to_i
  #   rec = rec.to_i
  #   if rec != 0 and rec != 1
  #     redirect_to root_path and return
  #   end
  #   if max < 0 or max > 100
  #     redirect_to list, flash: { danger: 'Maximum success rate should be between 0 and 100' } and return
  #   end
  #   redirect_to new_list_train_path(list, rec: rec, max: max)
  # end
  
  
  
  private
  def get_list
    @list = List.find_by_id(params[:id])
    if @list.nil?
      redirect_to root_path
    end
  end
  def get_list2
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
      []
    else
      list.wordsets.paginate(page: params[:page_ws], per_page: 30)
    end
  end
  def get_all_childs(list)
    if list.nil?
      current_user.root_lists
    else
      childs = list.childs
      if childs.nil?
        []
      else
        tot = childs
        childs.each do |ch|
          tot + get_all_childs(ch)
        end
        tot
      end
    end 
  end
  
  def get_data_show
    @path = get_path(@list)
    @childs = get_childs(@list)
    @words = get_words(@list)
    @wordsets = get_wordsets(@list)
    @i = 1
  end
end
