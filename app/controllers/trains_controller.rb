class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists, only: [:create] 
  before_filter :set_rec,     only: [:create] 
  before_filter :set_max,     only: [:create] 
  def new    
    if false
    words = ((@rec) ? @list.words_rec : @list.words)
    wordsets = get_wordsets(@list)
    words = [Word.find_by(239)]
    if @max < 100
      words = words.select do |word|
        word.success_count * 100 <= word.train_count * @max
      end
    end
    if words.empty?
      redirect_to @list,
        flash: { info: "There is no word for training" } and return
    end
    not_trained_yet = words.select do |w|
      not w.trained_by(current_user)
    end
    if not not_trained_yet.empty?
      @word = not_trained_yet.at(Random.rand(not_trained_yet.size))
    else
      require 'rubygems'
      require 'algorithms'
      q = Containers::PriorityQueue.new
      pool = words
      message = ""
      pool.each do |x|
        message += x.last_train(current_user).inspect
        q.push(x, Time.now - x.last_train(current_user).updated_at)
      end
      @word = q.next
    end
  end
  end
  
  def create
    @new_train = current_user.trains.build(list_id: @list.id, finished: false, success_ratio: 0.0, max: @max, actual_ws_id: -1)
    
    initialize_ws(@new_train, @list)
    if @new_train.save
      redirect_to @new_train, 
         flash: { success: "Train successfully created" } and return
    else
      flash_errors(@new_train)
      redirect_to @list and return
    end
  end
  
  
  def show
    @train = Train.find(params[:id]) 
    
    if not @train.actual_ws_id == -1
      if not params[:translation].nil?
        check_answer
        pick_new_ws
      end
    else
      pick_new_ws
    end
        
    
    if @train.actual_ws_id == -1
      @train.finished = true
      if not @train.save
        redirect_to root_path and return
      end
      redirect_to List.find(@train.list_id),
        flash: { success: "Train successfully ended" } and return
    end
    
    actual_ws = WordSet.find(@train.actual_ws_id)
    
    
    @word1 = Word.find(actual_ws.word1_id)
    @word2 = Word.find(actual_ws.word2_id)
    
  end
  
  

  private
  
  def initialize_ws(train, list)
    wordsets = get_wordsets(list)
    if wordsets.empty?
      redirect_to @list,
      flash: { info: "There is no word for training" } and return
    end
    ws_ids = []
    wordsets.each do |ws|
      if ws.success_ratio < @max
        ws_ids.push(ws.id)
      end
    end
    if ws_ids.empty?
      redirect_to @list,
        flash: { info: "There is no word for training" } and return
    end
    train.word_sets_ids = ws_ids.join(',')
  end
  
  def pick_new_ws
    ws_ids = @train.word_sets_ids
    if ws_ids.nil?
      @train.actual_ws_id = -1
    else 
      ws_ids_array = ws_ids.split(',')
      if ws_ids_array.empty?
        @train.actual_ws_id = -1
      else
        @train.actual_ws_id = ws_ids_array[rand(ws_ids_array.length)].to_i
        ws_ids_array.delete(@train.actual_ws_id.to_s)
        @train.word_sets_ids = ws_ids_array.join(',')        
      end
    end
    if not @train.save
      flash_errors(@train)
      redirect_to root_path and return
    end
  end
  
  def check_answer
    ws = WordSet.find(@train.actual_ws_id)
    word2 = Word.find(ws.word2_id) 
    if word2.content == params[:translation]
      ws.success += 1
    end
    ws.asked += 1
    ws.success_ratio = ws.success*100 / ws.asked
    if not ws.save
      redirect_to root_path and return
    end
  end

  def set_max
    if params[:train][:max].nil?
      raise params[:train][:max].to_s
      redirect_to root_path and return
    end
    @max = params[:train][:max].to_i
    if @max < 0 or @max > 100
      raise @max.to_s
      redirect_to root_path and return
    end
  end
  def set_rec
    @rec = (params[:train][:rec] == "1" ? 1 : 0)
  end
  def list_exists
    @list = List.find_by_id(params[:train][:list_id])
    if @list.nil?
      redirect_to root_path and return
    end
  end

  def get_wordsets(list)
    if list.nil?
      []
    else
      list.wordsets#.paginate(page: params[:page])
    end
  end
end
