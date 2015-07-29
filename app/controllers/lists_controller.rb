class ListsController < ApplicationController
  before_filter :signed_in_user
  before_filter :get_list, only: [:show, :edit, :destroy]
  before_filter :get_list2, only: [:moving, :move, :export, :exporting]
  before_filter :correct_user, only: [:show, :destroy, :deit, :moving, :move, :import, :export, :exporting]
  before_filter :get_data_show, only: [:new, :show, :move, :moving, :export, :exporting]
  before_filter :check_data_export, only: [:exporting]
  def new
    @new_list = current_user.lists.build
    if params[:list_id] && @list = List.find(params[:list_id])
      correct_user
      @lang1 = Language.find(@list.language1_id)
      @lang2 = Language.find(@list.language2_id)
    end
    render :show
  end
  def create
    @new_list = current_user.lists.build(name: params[:list][:name])
    @new_list.language1_id = params["language1_id"].to_i
    @new_list.language2_id = params["language2_id"].to_i
    @new_list.public_level = params["public_level"].to_i
    if params[:list_id] && @list = List.find(params[:list_id])
      correct_user
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
    @export = true
    render :show
  end
  def exporting 
    case params[:export][:format].to_i
    when 0 # .ovoc
      exporting_ovoc
    when 1 # .ods
      exporting_ods
    when 2 # .xlsx
      exporting_xlsx
    when 3 # .pdf
      exporting_pdf(@list)
    when 4 # .txt
      exporting_txt
    else
      redirect_to @list
    end
  end
  
  def public
    @publiclist = List.where(public_level: 10).paginate(page: params[:page], per_page: 30)
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
  def check_data_export
    if  params[:export].nil?
      redirect_to @list
    end
  end
  def correct_user
    user = @list.owner
    unless (user == current_user || @list.public_level == 10) 
      flash[:danger] = "You may not access this page"
      redirect_to(root_url) 
    end
  end
  
  
  def exporting_pdf(list)
    #
    # require "prawn"
    #
    # require "prawn/manual_builder"
    # Prawn::ManualBuilder::Example.generate("export.pdf") do
    #
    #
    #   table([ ["short", "short", "loooooooooooooooooooong"],
    #           ["short", "loooooooooooooooooooong", "short"],
    #           ["loooooooooooooooooooong", "short", "short"] ])
    # end
    
    Prawn::Document.generate("export.pdf") do
      text list.name, align: :center
      array = []

      list.wordsets.each do |ws|
        word1 = Word.find_by_id(ws.word1_id)
        word2 = Word.find_by_id(ws.word2_id)

        array.push([word1.content, word2.content])
      end

      table(array, position: :center, column_widths: [250,250])
    end
    
    send_file("export.pdf")
  end
  def exporting_txt
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
  
  def exporting_ovoc
    require 'nokogiri'
    content = Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.version 0.1
        xml.list{
          xml.name @list.name
          xml.language1_id @list.language1_id
          xml.language2_id @list.language2_id
          
          xml.wordsets {
            @list.wordsets.each do |ws|
              xml.wordset{
                xml.word1{
                  word1 = Word.find_by_id(ws.word1_id)
                  xml.id          word1.id
                  xml.content     word1.content
                  xml.language_id word1.language_id
                }
                xml.word2{
                  word2 = Word.find_by_id(ws.word2_id)
                  xml.id          word2.id
                  xml.content     word2.content
                  xml.language_id word2.language_id
                }
                xml.meaning1_id      ws.meaning1_id
                xml.meaning2_id      ws.meaning2_id
                
                if params[:export][:results].to_i == 1
                  xml.asked_qa         ws.asked_qa
                  xml.success_qa       ws.success_qa
                  xml.success_ratio_qa ws.success_ratio_qa
                  xml.asked_aq         ws.asked_aq
                  xml.success_aq       ws.success_aq
                  xml.success_ratio_aq ws.success_ratio_aq
                end
              }
            end
          }
          
          if params[:export][:trains].to_i == 1
            xml.trains {
              @list.trains.each do |t|
                xml.train {
                  xml.created_at          t.created_at
                  xml.updated_at          t.updated_at
                  xml.finished            t.finished
                  xml.success_ratio       t.success_ratio
                  xml.max                 t.max
                  xml.type_of_train       t.type_of_train
                  xml.error_policy        t.error_policy
                  xml.include_sub_lists   t.include_sub_lists
                  xml.fragments_list      t.fragments_list
                  xml.q_to_a              t.q_to_a
                  xml.finalized           t.finalized
                
                  xml.train_fragments {
                    t.fragments.each do |tf|
                      xml.train_fragment {
                        xml.id          tf.id
                        xml.sort        tf.sort
                        xml.q_to_a      tf.q_to_a
                        xml.word1_id    tf.word1_id
                        xml.word2_id    tf.word2_id
                        xml.answer      tf.answer
                        xml.is_correct  tf.is_correct 
                      }
                    end
                  }
                }
              end
            }
          end
        }
      }
    end
    send_data content.to_xml, filename: "export.ovoc" 
  end

end
