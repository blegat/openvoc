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
  before_filter :user_exists, only: [:edit, :update, :destroy]
  before_filter :allowed_user, only: [:edit, :update, :destroy]

  def new
    if signed_in? && current_user.registered?
      flash.now[:warning] = "You already have a registration.
        If you create another one, your existing registration
      will be destroyed."
    end
    @registration = Registration.new
    if signed_in?
      @registration.email = current_user.email
    end
    # FIXME prefill with name
  end
  
  def create
    #@registration = Registration.from_hash(params[:registration])
    if signed_in?
      @registration = current_user.build_registration(params[:registration])
      if @registration.save
        flash.now[:success] = "Succefully added registration."
        redirect_to authentications_path
      else
        flash_errors(@registration)
        render :new
      end
    else
      # Need to first verify if the registration is valid.
      # It is weird to show that the user is not valid
      # while the registration is not even valid yet.
      @registration = Registration.new(registration_params)
      @registration.skip_user_validation = true
      unless @registration.save
        flash_errors(@registration)
        render :new and return
      end
      user = User.build_with_registration(params)
      if user.save
        @registration.user = user
        @registration.skip_user_validation = false
        if @registration.save
          sign_in(user)
          flash.now[:success] = "Succefully registered."
          redirect_back_or authentications_path
        else
          @registration.destroy
          user.destroy
          flash_errors(registration)
          render :new
        end
      else
        @registration.destroy
        flash_errors(user)
        session[:current] = 'registration'
        session[:registration] = params[:registration]
        session[:name] = user.name
        session[:email] = user.email
        render "users/new"
      end
    end
  end
  
  def edit
    render_edit
  end
  def update
    @registration.email = params[:registration][:email]
    unless params[:registration][:new_password].blank?
      if @registration.authenticate(params[:registration][:current_password])
        @registration.password =
          params[:registration][:new_password]
        @registration.password_confirmation =
          params[:registration][:new_password_confirmation]
      else
        flash.now[:danger] = "Incorrect password"
        render_edit
      end
    end
    if @registration.save
      flash.now[:success] = "Successfully updated"
    else
      flash_errors @registration
    end
    render_edit
  end
  def destroy
    if @registration.user.auth_number == 1
      flash[:danger] = "This is your last authentication."
    else
      @registration.destroy
      flash[:success] = "Successfully destroyed registration."
    end
    redirect_to authentications_path
  end

  private

  def render_edit
    @registrations_edit = true
    @user = @registration.user
    render :edit, layout: 'settings' and return
  end
  def user_exists
    @registration = Registration.find_by_id(params[:id])
    if @registration.nil?
      redirect_to root_path
    end
  end
  def allowed_user
    unless current_user?(@registration.user)
      redirect_to root_path
    end
  end
  
  private
    def registration_params
      params.require(:registration).permit(:name,  :email, :password, :password_confirmation)
    end
  
end
