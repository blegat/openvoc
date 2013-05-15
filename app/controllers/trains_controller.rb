class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists
  before_filter :set_rec
  before_filter :set_max
  def new
    words = ((@rec) ? @list.words_rec : @list.words)
    if @max < 100
      words = words.select do |word|
        word.success_count * 100 <= word.train_count * @max
      end
    end
    if words.empty?
      redirect_to @list,
        flash: { notice: "There is no word for training" } and return
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
  def create
    @word = Word.find_by_id(params[:train][:word_id])
    @guess_content = params[:train][:guess]
    if @guess_content.blank?
      @guess_content = nil
    end
    if @word.nil?
      redirect_to root_path
    else
      @guess = @word.translations.find_by_content(@guess_content)
      @train = Train.new(success: !@guess.nil?,
                        guess: @guess_content)
      @train.user = current_user
      @train.word = @word
      unless @train.save
        flash_errors(@train)
      end
    end
  end
  def toggle_success
    # this gives access to the user the right to modify
    # any of its train
    @train = Train.find_by_id(params[:train_id])
    if @train.nil? or @train.user != current_user
      redirect_to root_path
    end
    @train.toggle!(:success)
    redirect_to new_list_train_path(@list, rec: @rec, max: @max)
  end

  private

  def set_max
    if params[:max].nil?
      raise params[:max].to_s
      redirect_to root_path
    end
    @max = params[:max].to_i
    if @max < 0 or @max > 100
      raise @max.to_s
      redirect_to root_path
    end
  end
  def set_rec
    @rec = (params[:rec] == "1" ? 1 : 0)
  end
  def list_exists
    @list = List.find_by_id(params[:list_id])
    if @list.nil?
      redirect_to root_path
    end
  end
end
