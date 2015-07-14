class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :get_train,   only: [:show]
  before_filter :get_train2,  only: [:finalize, :summary]
  before_filter :list_exists, only: [:create]
  before_filter :get_list,    only: [:show, :summary]  
  before_filter :set_rec,     only: [:create] 
  before_filter :set_max,     only: [:create]
  before_filter :init_create, only: [:create]
   
  def new
    @train = Train.new
    @list = List.find_by_id(params[:list_id])
    @lang1 = Language.find(@list.language1_id).name
    @lang2 = Language.find(@list.language2_id).name    
  end
  
  def create
    @new_train = current_user.trains.build(list_id: @list.id, finished: false, success_ratio: 0.0, 
          max: @max, type_of_train: params[:type_of_train].to_f, 
          include_sub_lists: params[:sub_lists].to_i == 1, error_policy: params[:error_policy].to_i, 
          fragments_list: "", fragment_pos: 0, q_to_a: params[:q_to_a].to_i, finalized: false)
                  
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
      apply_error_policy
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
  
  
  def finalize
    if @train.finalized == false
      list_tf = TrainFragment.where(train_id: @train.id)
      success = 0
      asked = 0
      list_tf.each do |tf|
        ws = WordSet.find(tf.word_set_id)
        asked += 1
        if tf.q_to_a
          ws.asked_qa += 1
          if tf.is_correct
            ws.success_qa += 1
            success += 1
          end
        else
          ws.asked_aq += 1
          if tf.is_correct
            ws.success_aq += 1
            success+= 1
          end
        end
        ws.compute_ratios
        ws.save
      end
      if asked != 0
        @train.success_ratio = (100 * success/asked) 
      end        
    end
    
    @train.finalized = true
    @train.save
    redirect_to train_summary_path(@train)
  end


  def summary
    @list_frag_succeeded = TrainFragment.where(train_id: @train.id, is_correct: true)
    @list_frag_failed    = TrainFragment.where(train_id: @train.id, is_correct: false)
  end
  
  def destroy
    train=Train.find(params[:id])
    train.fragments.each do |t|
      t.destroy
    end
    train.destroy
    redirect_to list_path(params[:list_id]), 
        flash: { success: "Train deleted" } and return
  end
  

  private
  
  def get_sub_wordsets(list)
    wordsets = WordSet.where(list_id:list.id)
    sublists = List.where(parent_id:list.id)
    if sublists.nil?
      return []
    else
      sublists.each do |sl|
        wordsets.concat(get_sub_wordsets(sl))
      end
    end
    return wordsets
  end
    
  def load_prev_frag(frag)
    @prev_word1 = Word.find(frag.word1_id)
    @prev_word2 = Word.find(frag.word2_id)
    @prev_answer = frag.answer
    @prev_correct= frag.is_correct
    puts 'HEREE'
    puts @prev_correct
  end
  
  def apply_error_policy
    if @train.error_policy == 1
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
  
  
  
  def initialize_fragments(train, list) 
    if train.include_sub_lists
      wordsets = get_sub_wordsets(list)
    else
      wordsets = WordSet.where(list_id:list.id)
    end

    
    wordsets.each do |ws|
      if train.q_to_a == 1 or train.q_to_a == 3
        if ws.success_ratio_qa <= @max
          new_fragment = train.fragments.build(word_set_id: ws.id, sort: 1, q_to_a: 1, 
                                               word1_id: ws.word1_id, word2_id: ws.word2_id, answer: "")
          if new_fragment.save
            add_fragment_id(train,new_fragment.id)
          end
        end
      end
      
      if train.q_to_a == 2 or train.q_to_a == 3
        if ws.success_ratio_aq <= @max
          new_fragment = train.fragments.build(word_set_id: ws.id, sort: 1, q_to_a: 2, 
                                               word1_id: ws.word2_id, word2_id: ws.word1_id, answer: "")
          if new_fragment.save
            add_fragment_id(train,new_fragment.id)
          end
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
  
  def init_create
    if params[:type_of_train].nil? || params[:sub_lists].nil? || params[:error_policy].nil?
      redirect_to @list and return
    end
  end
  
end

