class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :expires_now    # problems could appear if page is not fully reloaded
  before_filter :get_train,     only: [:show, :destroy]
  before_filter :get_train2,    only: [:finalize, :summary]
  before_filter :correct_user,  only: [:show, :finalize, :summary, :destroy]
  before_filter :get_list,      only: [:create]
  before_filter :get_list2,     only: [:show, :summary]
  before_filter :get_params_create, only: [:create]
  
   
  def new
    @train = Train.new
    @list = List.find_by_id(params[:list_id])
    @lang1 = Language.find(@list.language1_id).name
    @lang2 = Language.find(@list.language2_id).name    
  end
  
  def create
    @new_train = current_user.trains.build(list_id: @list.id, 
                                          finished: false, 
                                     success_ratio: 0.0, 
                                               max: @max, 
                                     type_of_train: @type_of_train, 
                                 include_sub_lists: @include_sub_lists, 
                                      error_policy: @error_policy, 
                                    fragments_list: "",
                                      fragment_pos: 0,
                                            q_to_a: @q_to_a, 
                                         finalized: false)
                  
    if @new_train.save
      initialize_fragments(@new_train, @list)
      
      if @new_train.fragments_list.empty?
        @new_train.destroy
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
      if not @train.save
        redirect_to root_url, flash: { error: "Problem while saving the train" } and return
      end
    end
    
    if pos >= 1
      @previous_frag = TrainFragment.find(get_nth_fragment(@train.fragment_pos - 1))
    end
    
    # ---
    
    if params[:modif_guess] && @previous_frag
      if params[:modif_guess][:to] == "true"
        @previous_frag.is_correct = true
        unapply_error_policy(@previous_frag)
      else
        @previous_frag.is_correct = false
        @train.finished = false
        apply_error_policy(@previous_frag)
      end
      if not (@previous_frag.save && @train.save)
        redirect_to root_url, flash: { error: "The modification could not be saved" } and return
      end
      redirect_to @train and return
      
    elsif params[:translation]
      check_fragment_and_apply_error_policy
      @train.fragment_pos += 1
      if not @train.save
        redirect_to root_url, flash: { error: "The train could not be saved. Thepage cannot be loaded" } and return
      end
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
        if not ws.save
          redirect_to root_url, flash: { error: "An error occured while finalizing the train - 1" } and return
        end
      end
      if asked != 0
        @train.success_ratio = (100 * success/asked) 
      end        
    end
    
    @train.finalized = true
    if not @train.save
      redirect_to root_url, flash: { error: "An error occured while finalizing the train - 2" } and return
    end
    redirect_to train_summary_path(@train)
  end

  def summary
    @list_frag_succeeded = TrainFragment.where(train_id: @train.id, is_correct: true)
    @list_frag_failed    = TrainFragment.where(train_id: @train.id, is_correct: false)
  end
  
  def destroy
    @train.fragments.each do |t|
      t.destroy
    end
    @train.destroy
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
    if frag.item1_is_word
      @prev_item1 = Word.find(frag.item1_id)
      @prev_content1 = @prev_item1.content
    else
      @prev_item1 = Meaning.find(frag.item1_id)
      @prev_content1 = @prev_item1.words_in_one_lang(Language.find(frag.language1_id))
    end
    
    if frag.item2_is_word
      @prev_item2 = Word.find(frag.item2_id)
      @prev_content2 = @prev_item2.content
    else
      @prev_item2 = Meaning.find(frag.item2_id)
      @prev_content2 = @prev_item2.words_in_one_lang(Language.find(frag.language2_id)) 
      
    end
    @prev_answer = frag.answer
    @prev_correct= frag.is_correct
  end
  
  def unapply_error_policy(frag)
    case @train.error_policy
    when 1
    when 2
      frag_to_remove = TrainFragment.where(train_id:@train.id, word_set_id:frag.word_set_id, q_to_a:frag.q_to_a).last
      old_list = @train.fragments_list
      if not (old_list.nil? or frag_to_remove.nil?)
        array = old_list.split(",")
        index = array.rindex(frag_to_remove.id.to_s) # get last index of an lement searched
        array.delete_at(index)
        @train.fragments_list = array.join(",")
        if not (frag_to_remove.destroy && @train.save)
          redirect_to root_url, flash: { error: "A problem occured while applying the unapply_error_policy" } and return
        end
      end
    end
  end
  
  def apply_error_policy(failed_frag)
    case @train.error_policy
    when 1
    when 2
      new_fragment = @train.fragments.build(word_set_id: failed_frag.word_set_id, 
                                                   sort: failed_frag.sort, 
                                                 q_to_a: failed_frag.q_to_a, 
                                               item1_id: failed_frag.item1_id, 
                                               item2_id: failed_frag.item2_id, 
                                          item1_is_word: failed_frag.item1_is_word,
                                          item2_is_word: failed_frag.item2_is_word,
                                           language1_id: failed_frag.language1_id,
                                           language2_id: failed_frag.language2_id,
                                                 answer: "")
      if not new_fragment.save
        redirect_to root_url, flash: { error: "A problem occured while applying the error_policy" } and return
      end
      old_list = @train.fragments_list
      if failed_frag == @actual_frag
        act_pos = @train.fragment_pos
      else
        act_pos = @train.fragment_pos - 1
      end
      if old_list.nil?
        @train.fragments_list = newid.to_s
      else
        array = old_list.split(",")
        if array.length == act_pos + 1 # if it is the last word, put new_fragment at the end (logical)
          array.insert(array.length,new_fragment.id)
        else # if not, don't put new_fragment just after the failed word
          array.insert(act_pos + 2 + rand(array.length-act_pos-1),new_fragment.id)
        end
        @train.fragments_list = array.join(",")
        if not @train.save
          redirect_to root_url, flash: { error: "A problem occured while applying the error_policy 2" } and return
        end
      end
    end
  end
  
  def check_fragment_and_apply_error_policy
    @actual_frag.answer = params[:translation]
    
    if check_answer_only(@item2, @item2_is_word, @actual_frag.language2_id, @actual_frag.answer)
      @actual_frag.is_correct = true
    else
      @actual_frag.is_correct = false
      apply_error_policy(@actual_frag)
    end
    if not @actual_frag.save
      redirect_to root_url, flash: { error: "A problem occured while checking your answer" } and return
    end
  end
  
  def load_fragment(frag)
    @sort = frag.sort
    if @sort == 1
      @item1_is_word = frag.item1_is_word
      @item2_is_word = frag.item2_is_word
      if @item1_is_word
        @item1 = Word.find(frag.item1_id)
        @content1 = @item1.content
      else
        @item1 = Meaning.find(frag.item1_id)
        @content1 = @item1.words_in_one_lang(Language.find(frag.language1_id))
      end
      
      if @item2_is_word
        @item2 = Word.find(frag.item2_id)
        @content2 = @item2.content
      else
        @item2 = Meaning.find(frag.item2_id)
        @content2 = @item2.words_in_one_lang(Language.find(frag.language2_id)) 
      end
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
                                               item1_id: ws.word_id, item2_id: ws.meaning_id,
                                               item1_is_word: true, item2_is_word: false,
                                               language1_id: ws.list.language1_id, language2_id: ws.list.language2_id,
                                               answer: "")
          if new_fragment.save
            add_randomly_fragment_id(train,new_fragment.id)
          end
        end
      end
      
      if train.q_to_a == 2 or train.q_to_a == 3
        if ws.success_ratio_aq <= @max
          new_fragment = train.fragments.build(word_set_id: ws.id, sort: 1, q_to_a: 2, 
                                               item1_id: ws.meaning_id, item2_id: ws.word_id, 
                                               item1_is_word: false, item2_is_word: true,
                                               language1_id: ws.list.language2_id, language2_id: ws.list.language1_id,
                                               answer: "")
          if new_fragment.save
            add_randomly_fragment_id(train,new_fragment.id)
          end
        end  
      end
    end
    
    train.fragment_pos = 0
    train.save
  end
  
  def add_randomly_fragment_id(train,newid)
    old_list = train.fragments_list
    if old_list.nil?
      train.fragments_list = newid.to_s
    else
      array = old_list.split(",")
      array.insert(rand(array.length+1),newid)
      train.fragments_list = array.join(",")
    end
  end
  
  def check_answer_only(item, is_word, lang_id, answer)
    if is_word
      return item.content == answer
    else
      item.words.where(language_id:lang_id).each do |w|
        if w.content == answer
          return true
        end
      end
    end
    return false
  end
  
  def check_answer
    @previous_ws = WordSet.find(@train.actual_ws_id)

    if check_answer_only(@previous_ws.item2, @previous_ws.item2_is_word, 
                         @previous_ws.language2_id, params[:translation])
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

  def get_params_create
    @rec = (params[:train][:rec] == "1" ? 1 : 0)
    
    if params[:train][:max].nil?
      raise params[:train][:max].to_s
      redirect_to root_path and return
    end
    @max = params[:train][:max].to_i
    if @max < 0 or @max > 100
      raise @max.to_s
      redirect_to root_path and return
    end
    
    if params[:train][:type_of_train].nil?
      raise params[:train][:type_of_train].to_s
      redirect_to root_path and return
    end
    @type_of_train = params[:train][:type_of_train].to_i
    if not @type_of_train.in?([1, 2, 3])
      raise @type_of_train.to_s
      redirect_to root_path and return
    end
    
    if params[:train][:type_of_train].nil?
      raise params[:train][:type_fo_train].to_s
      redirect_to root_path and return
    end
    @type_of_train = params[:train][:type_of_train].to_i
    if not @type_of_train.in?([1, 2, 3])
      raise @type_of_train.to_s
      redirect_to root_path and return
    end
    
    @include_sub_lists = (params[:train][:include_sub_lists] == "1" ? true : false)
    
    if params[:train][:error_policy].nil?
      raise params[:train][:error_policy].to_s
      redirect_to root_path and return
    end
    @error_policy = params[:train][:error_policy].to_i
    if not @error_policy.in?([1, 2])
      raise @error_policy.to_s
      redirect_to root_path and return
    end
    
    if params[:train][:q_to_a].nil?
      raise params[:train][:q_to_a].to_s
      redirect_to root_path and return
    end
    @q_to_a = params[:train][:q_to_a].to_i
    if not @q_to_a.in?([1, 2, 3])
      raise @q_to_a.to_s
      redirect_to root_path and return
    end
    
  end

  def get_list
    @list = List.find_by_id(params[:train][:list_id])
    if @list.nil?
      redirect_to root_path and return
    end
  end

  def get_list2
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
  
  def correct_user
    user = User.find(@train.user_id)
    redirect_to(root_url) unless user == current_user
  end
  
end

