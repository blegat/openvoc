class ListsController < ApplicationController
  before_filter :signed_in_user
  before_filter :create_group_and_user
  before_filter :get_list, only: [:show, :edit, :destroy]
  before_filter :get_list2, only: [:moving, :move, :export, :exporting, :prepare_data_to_add]
  before_filter :correct_user, only: [:index, :show, :destroy, :edit, :moving, :move, :import, :export, :exporting]
  before_filter :get_data_show, only: [:new, :show, :moving, :export, :exporting]
  before_filter :check_data_export, only: [:exporting]
  def new
    @new_list = @user.lists.build
    if params[:list_id] && @list = List.find(params[:list_id])
      correct_user
      @lang1 = Language.find(@list.language1_id)
      @lang2 = Language.find(@list.language2_id)
    end
    render :show
  end
  def create
    @new_list = @user.lists.build(name: params[:list][:name])
    @new_list.language1_id = params["language1_id"].to_i
    @new_list.language2_id = params["language2_id"].to_i
    @new_list.public_level = params["public_level"].to_i
    if params[:list_id] && @list = List.find(params[:list_id])
      correct_user
      @new_list.parent = @list
    end
    if @new_list.save
      flash.now[:success] = "#{@new_list.name} successfully created"
      redirect_to path_for_list(@new_list, @group)
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
    @childs = @user.root_lists
    @groups_list = @current_user.groups
    render :show
  end
  def show
    @language1 = Language.find_by_id(@list.language1_id)
    @language2 = Language.find_by_id(@list.language2_id)
    @trains = Train.where(list_id:@list.id, user_id:current_user.id).paginate(page: params[:page_trains], per_page: 5)
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

    redirect_to path_for_root_list(@group),
        flash: { success: "List deleted" } and return
  end
  def edit
    prepare_for_edit
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
      if @dest.nil? or @dest.owner != @user or
        @dest == @list or @dest.in?(@list.rec_parents)
        @moving = true
        flash.now[:danger] = "Invalid destination"
      else
        @list.parent = @dest
        @list.save
      end
    end
    get_data_show
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

  def prepare_data_to_add
    dataToAdd = params[:wordset][:data_to_add]
    @dataPrepared={}
    hash = Hash.new
    if dataToAdd
      dataToAdd = dataToAdd.split("\r\n") # FIXME if error maybe here...
      # Added from the list
      list = List.find_by(id:params[:wordset][:list_id])

      dataToAdd.each_with_index do |dta, index|
        newWords = dta.split('=')
        newWords[0] = delete_blanks(newWords[0])
        newWords[1] = delete_blanks(newWords[1])
        @dataPrepared[index.to_s] = {}
        @dataPrepared[index.to_s][:word0]={}
        @dataPrepared[index.to_s][:word1]={}
        @dataPrepared[index.to_s][:link]={}
        
        @dataPrepared[index.to_s][:word0][:value]=newWords[0]
        @dataPrepared[index.to_s][:word1][:value]=newWords[1]
        
        
        @dataPrepared[index.to_s][:word0][:should_be_created]=true
        @dataPrepared[index.to_s][:word1][:should_be_created]=true

        word1 = Word.find_by(content:newWords[0], language_id:list.language1_id)
        word2 = Word.find_by(content:newWords[1], language_id:list.language2_id)
        if word1
          @dataPrepared[index.to_s][:word0][:should_be_created]=false
          @dataPrepared[index.to_s][:word0][:id]=word1.id
        end
        if word2
          @dataPrepared[index.to_s][:word1][:should_be_created]=false
          @dataPrepared[index.to_s][:word1][:id]=word2.id
        end

        common_meanings = []
        if word1 && word2
          common_meanings = word1.common_meanings(word2)
          puts 'word1_id'
          puts word1.id
          puts 'word2_id'
          puts word2.id
          puts 'HEREE'
          puts common_meanings.length
        end
        

        if common_meanings.length == 0 && !word1 && !word2
          @dataPrepared[index.to_s][:link][:should_be_created]=true
          
        elsif common_meanings.length == 0
          @dataPrepared[index.to_s][:link][:should_be_selected]=true
        
        elsif  common_meanings.length >= 1 #TODO what to do?
          @dataPrepared[index.to_s][:link][:already_exists]=true
        end
      end
    end  
    prepare_for_edit
    render :edit
  end


  private
  def create_group_and_user
    if params[:group_id]
      @group = Group.find(params[:group_id])
      @user = User.find(@group.faker_id)
    else
      @user = current_user
    end
  end
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
      @user.root_lists
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
      @useruser.root_lists
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
    if ((params[:action] == "index") && @group.nil?)
      return
    end

    if @list
      test1 = (@list.owner == current_user)
      test2 = (@list.public_level == 10)
      if @group
        test3 = @group.has_list?(@list) && current_user.is_member?(@group)
        test4 = @group.public?
      end
    else
      if @group
        test5 = (current_user.is_member?(@group)) && (not @list)
        test6 = @group.public?
      end
    end

    unless ( test1 || test2 || test3 || test4 || test5 || test6)
      if @list && (not @group) && @list.owner.faker?
        supposed_group = @list.owner.faker_of_group
        if current_user.is_member?(supposed_group)
          redirect_to group_list_path(supposed_group, @list)
          return
        end
      end
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

  def path_for_list(list,group)
    if group.nil?
      list_path(list)
    else
      group_list_path(group, list)
    end
  end

  def path_for_root_list(group)
    if group.nil?
      lists_path
    else
      group_lists_path(group)
    end
  end
  
  def delete_blanks(input)
    max_length = input.length
    i=0
    j=input.length - 1
    k=0
    output=""

    while (i < max_length && input[i].blank?) do
      i=i+1
    end

    while (j >= 0 && input[j].blank?) do
      j=j-1
    end

    while k < max_length do
      if k >= i && k <= j
        output = "#{output}#{input[k]}"
      end
      k = k +1
    end

    return output
  end
  
  def prepare_for_edit
    @path = @list.path
    @wordsets = get_wordsets(@list)
    @language1_name = Language.find_by(id:@list.language1_id).name
    @language2_name = Language.find_by(id:@list.language2_id).name
    @language1 = Language.find_by(id:@list.language1_id)
    @language2 = Language.find_by(id:@list.language2_id)
    @languages = Language.all
  end

end
