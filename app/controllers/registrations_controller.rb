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

class RegistrationsController < ApplicationController
  def new
    if signed_in? && current_user.registered?
      flash.now[:notice] = "You already have a registration.
        If you create another one, your existing registration
      will be destroyed."
    end
    @registration = Registration.new
    if signed_in?
      @registration.email = current_user.email
    end
  end
  def create
    #@registration = Registration.from_hash(params[:registration])
    if signed_in?
      @registration = current_user.build_registration(params[:registration])
    else
      @user = User.new
      @registration = @user.build_registration(params[:registration])
      @user.update_name(params[:name])
      @user.update_email(@registration.email)
      # update_email is necessary for the user to be valid
      # email is unique and 2 nil email is the same
      unless @user.save
        flash_errors @user
        render :new and return
      end
    end
    if @registration.save
      #TODO check uniqueness of email
      if signed_in?
        current_user.update_email(@registration.email)
        flash.now[:success] = "Succefully added registration."
      else
        sign_in(@user)
        flash.now[:success] = "Succefully registered."
      end
      redirect_back_or authentications_path
    else
      unless signed_in?
        @user.destroy
      end
      flash_errors(@registration)
    end
  end
  def destroy
    if current_user.auth_number == 1
      flash[:error] = "This is your last authentication."
    else
      current_user.registration.destroy
      flash[:success] = "Successfully destroyed registration."
    end
    redirect_to authentications_path
  end
end
