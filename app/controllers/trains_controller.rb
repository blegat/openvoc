class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :get_train,   only: [:show]
  before_filter :get_train2,  only: [:summary]
  before_filter :list_exists, only: [:create]
  before_filter :get_list,    only: [:show, :summary]  
  before_filter :set_rec,     only: [:create] 
  before_filter :set_max,     only: [:create]
  before_filter :init_create, only: [:create]
   
  def new
    @train = Train.new
    @list = List.find_by_id(params[:list_id])
  end
  
  def create
    @new_train = current_user.trains.build(list_id: @list.id, finished: false, success_ratio: 0.0, 
          max: @max, actual_ws_id: -1, word_sets_ids_succeeded: "", word_sets_ids_failed: "", 
          type_of_train: params[:type_of_train].to_f, include_sub_lists: params[:sub_lists].to_i, 
          ask_policy: params[:ask_policy].to_i, fragments_list: "", fragment_pos: 0)
    
    
    # initialize_ws(@new_train, @list)
    

    if @new_train.save
      initialize_fragments(@new_train, @list)
      
      if @new_train.fragments_list.empty?
        redirect_to @list, flash: { info: "There is no word for training" } and return
      end
      
      redirect_to @new_train, 
         flash: { success: "Train successfully created" } and return
    else
      flash_errors(@new_train)
      redirect_to @list and return
    end
  end
  
  # def show
  #   @guessTrue = false
  #   @guessFalse = false
  #
  #   if params[:modif_guess]
  #     @previous_ws = WordSet.find(params[:modif_guess][:ws_id])
  #     @previous_ws_id = params[:modif_guess][:ws_id]
  #     @previous_word1 = Word.find(@previous_ws.word1_id)
  #     @previous_word2 = Word.find(@previous_ws.word2_id)
  #     if params[:modif_guess][:to] == "true"
  #       @guessTrue = true
  #       @previous_ws.success += 1
  #       last_id=pop_last_failed
  #       add_id_to_succeeded(last_id)
  #     else
  #       @guessFalse = true
  #       @previous_ws.success -= 1
  #       last_id=pop_last_succeeded
  #       add_id_to_failed(last_id)
  #     end
  #     @previous_ws.success_ratio = @previous_ws.success*100 / @previous_ws.asked
  #     if not @previous_ws.save
  #       redirect_to root_path and return
  #     end
  #
  #   elsif (not @train.actual_ws_id == -1)
  #     @previous_ws_id = @train.actual_ws_id
  #     if not params[:translation].nil?
  #       check_answer
  #       pick_new_ws
  #     end
  #   else
  #     pick_new_ws
  #   end
  #
  #
  #   if @train.actual_ws_id == -1
  #     @train.finished = true
  #     if not @train.save
  #       redirect_to root_path and return
  #     end
  #
  #   else
  #     actual_ws = WordSet.find(@train.actual_ws_id)
  #     @word1 = Word.find(actual_ws.word1_id)
  #   end
  #
  # end
  
  
  
  def show
    pos = @train.fragment_pos
    
    if pos < get_nb_of_fragments
      @actual_frag = TrainFragment.find(get_nth_fragment(@train.fragment_pos))
      load_fragment(@actual_frag)
    else
      @train.finished = true
      @train.save
    end
    
    if pos >= 1
      @previous_frag = TrainFragment.find(get_nth_fragment(@train.fragment_pos - 1))
    end
    
    # ---
    
    if params[:modif_guess] && @previous_frag
      if params[:modif_guess][:to] == "true"
        @previous_frag.is_correct = true
      else
        @previous_frag.is_correct = false
      end
      @previous_frag.save
      
    elsif params[:translation]
      check_fragment
      apply_ask_policy
      @train.fragment_pos += 1
      @train.save
      redirect_to @train
    else
      # nothing special to do
    end
    
    # ---
    
    if @previous_frag
      load_prev_frag(@previous_frag)
    end
    
  end
  
  
  # def summary
  #   @list_id_succeeded = @train.word_sets_ids_succeeded.split(',')
  #   @list_id_failed = @train.word_sets_ids_failed.split(',')
  # end

  def summary
    @list_frag_succeeded = TrainFragment.where(train_id: @train.id, is_correct: true)
    @list_frag_failed    = TrainFragment.where(train_id: @train.id, is_correct: false)
  end
  
  

  private
  
  def load_prev_frag(frag)
    @prev_word1 = Word.find(frag.word1_id)
    @prev_word2 = Word.find(frag.word2_id)
    @prev_answer = frag.answer
    @prev_correct= frag.is_correct
    puts 'HEREE'
    puts @prev_correct
  end
  
  def apply_ask_policy
    if @train.ask_policy == 1
    end
  end
  
  def check_fragment
    @actual_frag.answer = params[:translation]
    if @word2f.content == @actual_frag.answer
      @actual_frag.is_correct = true
    else
      @actual_frag.is_correct = false
    end
    @actual_frag.save
  end
  
  def load_fragment(frag)
    @sort = frag.sort
    if @sort == 1
      @word1f = Word.find(frag.word1_id)
      @word2f = Word.find(frag.word2_id)
    end
  end
  
  
  
  def get_nb_of_fragments
    @train.fragments_list.split(',').length
  end
  
  def get_nth_fragment(n)
    array = @train.fragments_list.split(',')
    array[n].to_i
  end
  
  
  # def initialize_ws(train, list)
  #   wordsets = get_wordsets(list)
  #   if wordsets.empty?
  #     train.word_sets_ids = nil
  #     return
  #   end
  #   ws_ids = []
  #   wordsets.each do |ws|
  #     if ws.success_ratio <= @max
  #       ws_ids.push(ws.id)
  #     end
  #   end
  #   if ws_ids.empty?
  #     train.word_sets_ids = nil
  #     return
  #   end
  #   train.word_sets_ids = ws_ids.join(',')
  # end
  
  
  
  def initialize_fragments(train, list) 
    wordsets = get_wordsets(list)
    if wordsets.empty?
      train.fragments_list = nil
      return
    end
    
    wordsets.each do |ws|
      if ws.success_ratio <= @max
        new_fragment = train.fragments.build(word_set_id: ws.id, sort: 1, q_to_a: 1, word1_id: ws.word1_id, word2_id: ws.word2_id, answer: "")

        if new_fragment.save
          add_fragment_id(train,new_fragment.id)
        end
      end
    end
    train.fragment_pos = 0
    train.save
  end
  
  
  def add_fragment_id(train,newid)
    old_list = train.fragments_list
    if old_list.nil?
      train.fragments_list = newid.to_s
    else
      array = old_list.split(",")
      array.insert(rand(array.length+1),newid)
      train.fragments_list = array.join(",")
    end
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
    @previous_ws = WordSet.find(@train.actual_ws_id)
    @previous_word1 = Word.find(@previous_ws.word1_id) 
    @previous_word2 = Word.find(@previous_ws.word2_id)
    if @previous_word2.content == params[:translation]
      @guessTrue = true
      @previous_ws.success += 1
      add_id_to_succeeded(@previous_ws.id)
    else
      @guessFalse = true
      ws_ids_failded = @train.word_sets_ids_failed
      add_id_to_failed(@previous_ws.id)
    end
    @previous_ws.asked += 1
    @previous_ws.success_ratio = @previous_ws.success*100 / @previous_ws.asked
    if not @previous_ws.save
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

  def get_list
    @list = List.find_by_id(@train.list_id)
    if @list.nil?
      redirect_to root_path and return
    end
  end
  
  def get_train
    @train = Train.find_by_id(params[:id])
    if @train.nil?
      redirect_to root_path and return
    end
  end
  
  def get_train2
    @train = Train.find_by_id(params[:train_id])
    if @train.nil?
      redirect_to root_path and return
    end
  end
  
  def get_wordsets(list)
    if list.nil?
      []
    else
      list.wordsets
    end
  end

  # def add_id_to_succeeded(id)
  #   ws_ids_succeeded = @train.word_sets_ids_succeeded
  #   if ws_ids_succeeded.nil?
  #     redirect_to root_path,
  #         flash: { error: "An error occured" }  and return
  #   else
  #     ws_ids_array = ws_ids_succeeded.split(',')
  #     if ws_ids_array.empty?
  #       @train.word_sets_ids_succeeded = id.to_s
  #     else
  #       ws_ids_array.push(id.to_s)
  #       @train.word_sets_ids_succeeded = ws_ids_array.join(',')
  #     end
  #   end
  #   if not @train.save
  #     flash_errors(@train)
  #     redirect_to root_path and return
  #   end
  # end
  
  # def add_id_to_failed(id)
  #   ws_ids_fail = @train.word_sets_ids_failed
  #   if ws_ids_fail.nil?
  #     redirect_to root_path,
  #         flash: { error: "An error occured" }  and return
  #   else
  #     ws_ids_array = ws_ids_fail.split(',')
  #     if ws_ids_array.empty?
  #       @train.word_sets_ids_failed = id.to_s
  #     else
  #       ws_ids_array.push(id.to_s)
  #       @train.word_sets_ids_failed = ws_ids_array.join(',')
  #     end
  #   end
  #   if not @train.save
  #     flash_errors(@train)
  #     redirect_to root_path and return
  #   end
  # end
  
  # def pop_last_failed
  #   ws_ids_fail = @train.word_sets_ids_failed
  #   if ws_ids_fail.nil?
  #     redirect_to root_path,
  #         flash: { error: "An error occured" }  and return
  #   else
  #     ws_ids_array = ws_ids_fail.split(',')
  #     if ws_ids_array.empty?
  #       redirect_to root_path,
  #           flash: { error: "An error occured: array is not empty" }  and return
  #     else
  #       last_id=ws_ids_array.pop
  #       @train.word_sets_ids_failed = ws_ids_array.join(',')
  #     end
  #   end
  #   if not @train.save
  #     flash_errors(@train)
  #     redirect_to root_path and return
  #   end
  #   last_id
  # end
  
  # def pop_last_succeeded
  #   ws_ids_succeeded = @train.word_sets_ids_succeeded
  #   if ws_ids_succeeded.nil?
  #     redirect_to root_path,
  #         flash: { error: "An error occured" }  and return
  #   else
  #     ws_ids_array = ws_ids_succeeded.split(',')
  #     if ws_ids_array.empty?
  #       redirect_to root_path,
  #           flash: { error: "An error occured" }  and return
  #     else
  #       last_id=ws_ids_array.pop
  #       @train.word_sets_ids_succeeded = ws_ids_array.join(',')
  #     end
  #   end
  #   if not @train.save
  #     flash_errors(@train)
  #     redirect_to root_path and return
  #   end
  #   last_id
  # end
  
  def init_create
    if params[:type_of_train].nil? || params[:sub_lists].nil? || params[:ask_policy].nil?
      redirect_to @list and return
    end
  end
  
end

