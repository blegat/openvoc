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

class UsersController < ApplicationController
  def new
  end
  def create
    # When there is a missing name in an omniauth,
    # users/new is called and here we are

    session['name'] = params[:user][:name]
    session['email'] = params[:user][:email]

    user = User.new(name: session[:name], email: session[:email])
    if user.save
      if session[:current] == 'omniauth'
        auth = user.build_omniauth(session[:omniauth])
      else
        auth = user.build_registration(session[:registration])
      end
      if auth.save
        flash.now[:success] = "Created successfully"
        sign_in(user)
        @user = user
        render :show and return
      else
        # Weird case, give up everything
        user.destroy
        unless auth.errors.empty?
          flash.now[:error] = auth.errors.full_messages.to_sentence
        end
        redirect_to authentications_path
      end
    else
      unless user.errors.empty?
        flash.now[:error] = user.errors.full_messages.to_sentence
      end
    end
    render :new
  end
  def show
    @user = User.find(params[:id])
  end
  def edit
    @user = User.find(params[:id])
  end
  def update
    @user = User.find(params[:id])
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    if @user.save
      flash.now[:success] = "Successfully updated"
    else
      unless @user.errors.empty?
        flash.now[:error] = @user.errors.full_messages.to_sentence
      end
    end
    render :edit
  end
end
