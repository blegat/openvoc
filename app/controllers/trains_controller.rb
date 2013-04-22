class TrainsController < ApplicationController
  before_filter :signed_in_user
  before_filter :list_exists
  def new
    if @list.words.empty?
      redirect_to @list,
        flash: { notice: "The list contains no word" } and return
    end
    already_trained =
      @list.words.joins(:trains).where(trains: { user_id: current_user.id }).uniq#.group_by(:word).order(:created_at)
    # if not uniq, it try to delete it twice
    if already_trained.to_a.count < @list.words.count
      pool = @list.words.select { |x| !already_trained.include?(x) }
      flash[:notice] = pool.to_s
      #@word = pool.random #not working :(
      pool_a = pool.to_a
      @word = pool_a.at(Random.rand(pool_a.size))
    else
      require 'rubygems'
      require 'algorithms'
      q = Containers::PriorityQueue.new
      pool = @list.words
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
