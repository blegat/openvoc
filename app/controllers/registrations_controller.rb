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
      @user.save
    end
    if @registration.save
      #TODO check uniqueness of email
      unless signed_in?
        sign_in(@user)
        flash.now[:success] = "Succefully logged in"
      end
      current_user.update_email(@registration.email)
      render :new
    else
      unless signed_in?
        @user.destroy
      end
      #flash.now[:error] = "Fail"
      unless @registration.errors.empty? # that would be weird :o
        flash.now[:notice] = @registration.errors.full_messages.to_sentence
      end
      unless @user.errors.empty?
        flash.now[:notice] = @user.errors.full_messages.to_sentence
      end
      render :new
    end
  end
  def destroy
    current_user.registration.destroy
    flash[:notice] = "Successfully destroyed registration."
    redirect_to authentications_path
  end
end
