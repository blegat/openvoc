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
  before_filter :user_exists, only: [:edit, :update, :destroy, :show]
  before_filter :allowed_user, only: [:edit, :update]

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
        # it normally has already been checked.
        # It must be that someone has registered with that email
        # while redirecting to users/new
        user.destroy
        flash_errors(auth)
        if session[:current] == 'omniauth'
          redirect_to authentications_path and return
        else
          @registration = auth
          render new_registration_path and return
        end
      end
    else
      flash_errors user
    end
    render :new
  end
  
  def show
  end
  
  def edit
    @users_edit = true
    render layout: 'settings'
  end
  
  def update
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    if @user.save
      flash.now[:success] = "Successfully updated"
    else
      flash_errors @user
    end
    @users_edit = true
    render :edit, layout: 'settings'
  end

  private

  def user_exists
    @user = User.find_by_id(params[:id])
    if @user.nil?
      redirect_to root_path
    end
  end
  
  def allowed_user
    unless current_user?(@user)
      redirect_to root_path
    end
  end
end
