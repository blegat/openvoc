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

class AuthenticationsController < ApplicationController

  before_filter :signed_in_user, only: [:destroy]

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      if signed_in?
        # Trying to add an authentication to a user
        if current_user?(authentication.user)
          flash[:notice] = "You already have this authentication"
        else
          flash[:error] = "This authentication is already used by another user"
        end
        redirect_to authentications_path
      else
        # Trying to connect
        flash[:notice] = "Logged in successfuly";
        sign_in(authentication.user)
        redirect_back_or authentication.user
      end
    elsif signed_in?
      authentication = current_user.build_omniauth(omniauth)
      if authentication.save
        flash[:notice] = "Authentication successfully added."
        redirect_to authentications_path
        # redirect is necessary because @authentications
        # must be calculated for the views
      else
        unless authentication.errors.empty? # that would be weird :o
          flash[:notice] = authentication.errors.full_messages.to_sentence
        end
      end
    else
      # if omniauth[:info][:name].blank? or
      #   omniauth[:info][:email].blank?
      #   # user is invalid without a name and an email
      #   session[:omniauth] = omniauth
      #   render "users/new" and return
      # end
      user = User.build_with_omniauth(omniauth)
      if user.save
        flash[:notice] = "Account created"
        authentication = user.build_omniauth(omniauth)
        if authentication.save
          flash[:success] = "Signed in successfully."
          sign_in(user)
          redirect_back_or user
        else
          flash[:error] = "ERROR"
          session[:omniauth] = omniauth.except('extra')
          render :index
        end
      else
        #flash[:error] = "There is already a user with the same email"
        unless user.errors.empty?
          flash_errors(user)
        end
        # if session[:omniauth].nil? is not safe on UsersControlleer
        # because it could be the registration after an omniauth
        # if session[:current] == 'omniauth' is ok
        session[:current] = 'omniauth'
        session[:omniauth] = omniauth.except('extra')
        session[:name] = user.name
        session[:email] = user.email
        render "users/new"
        #redirect_to new_user_registration_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if @authentication.nil? or @authentication.user != current_user
      redirect_to root_path
    end
    if @authentication.user.auth_number == 1
      flash[:error] = "This is your last authentication."
    else
      @authentication.destroy
      flash[:success] = "Successfully destroyed authentication."
    end
    redirect_to authentications_path
  end

end
