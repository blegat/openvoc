class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists
  def new
    if @list.words.empty?
      redirect_to @list,
        flash: { notice: "The list contains no word" } and return
    end
    words = ((params[:rec] == "true") ? @list.words_rec : @list.words)
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
      train = Train.new(success: !@guess.nil?,
                        guess: @guess_content)
      train.user = current_user
      train.word = @word
      puts Train.count
      unless train.save
        flash_errors(train)
      end
      puts Train.count
    end
  end

  private

  def list_exists
    @list = List.find_by_id(params[:list_id])
    if @list.nil?
      redirect_to root_path
    end
  end
end
