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
    @omniauth = session[:omniauth]
    @omniauth['info']['name'] = params[:user][:name]
    user = User.create_with_omniauth(@omniauth)
    authentication = user.apply_omniauth(@omniauth)
    @user = user
    if user.save
      if authentication.save
        user.update_with_omniauth(@omniauth,
                                  authentication)
        flash.now[:success] = "Created successfully"
        sign_in(user)
        render :show and return
      else
        unless authentication.errors.empty?
          flash.now[:error] = authentication.errors.full_messages.to_sentence
        end
      end
    else
      unless user.errors.empty?
        flash.now[:error] = user.errors.full_messages.to_sentence
      end
    end
    render :new
  end
  def edit
    @user = User.find(params[:id])
  end
  def update
    @user = User.find(params[:id])
    if @user.registered?
      @user.update_email(params[:user][:email])
    else
      authentication = Authentication.find(params[:user][:email_src][:id])
      if @user.authentications.include?(authentication)
        flash.now[:notice] = "Updated"
        @user.update_email_src(authentication)
      else
        # this shouldn't happen for a non-hacker
        flash.now[:error] = "This authentication is not in yours"
      end
    end
    render :edit
  end
end
