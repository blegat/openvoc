### BEGIN LICENSE
# Copyright (C) 2012 Benoît Legat benoit.legat@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
### END LICENSE

class WordsController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :destroy]

  def index
  end

  def show
    @word = Word.find(params[:id])
  end

  def new
    @language = Language.find(params[:language_id])
    @words = @language.words.paginate(page: params[:page])
    @new_word = true
    render 'languages/show', location: language_path(@language)
  end

  def create
    @language = Language.find(params[:language_id])
    @words = @language.words.paginate(page: params[:page])
    @new_word = true
    @word = @language.words.build(content: params[:word][:content])
    @word.owner = current_user
    if @word.save
      flash.now[:success] = "#{@word.content} added to #{@language.name}"
      render 'languages/show'
      #redirect_to new_language_word_path
      # I need to change the url because otherwise,
      # when the user change the page a GET request
      # is sent to language_words_path which insn't defined
    else
      flash_errors(@word)
      render :new
    end
  end

  def destroy
    if params[:list_id].nil?
      # destroy the word
      @word = Word.find_by_id(params[:id])
      if @word.nil? or @word.owner != current_user
        # can only be removed by the owner if no list is using it and no link
        redirect_to root_path
      elsif not @word.lists.empty?
        redirect_to @word, flash: { danger: "The word is being used by a list" }
      elsif not @word.links2.empty?
        redirect_to @word, flash: { danger: "The word is being used by a link" }
      else
        language = @word.language
        @word.destroy
        flash.now[:success] = "Successfully destroyed"
        redirect_to language
      end
    else
      # remove the word from a list
      @list = List.find_by_id(params[:list_id])
      if @list.nil? or @list.owner != current_user
        redirect_to root_path
      end
      @word = Word.find_by_id(params[:id])
      if @word.nil? or not @list.words.include?(@word)
        redirect_to root_path
      end
      @list.words.delete(@word)
      redirect_to @list, flash: { success: "Successfully removed from the list" }
    end
  end
end
