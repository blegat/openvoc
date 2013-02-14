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

  #def sign_in(user)
    #session[:user_id] = user.id
  #end

  #def current_user
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
  #end

  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:success] = "Authentication"
      if signed_in?
        # Trying to add an authentication to a user
        if current_user?(authentication.user)
          flash[:notice] = "You already have this authentication"
        else
          flash[:error] = "This authentication is already used by another user"
          render :index
        end
      else
        # Trying to connect
        flash[:notice] = "Logged in successfuly";
        sign_in(authentication.user)
        redirect_to users_path(authentication.user)
      end
    elsif signed_in?
      flash[:success] = "current_user #{current_user.id}"
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      flash[:success] = "Nothing"
      user = User.new
      user.apply_omniauth(omniauth)
      if user.valid?
        user.save!
        # saving could fail if the db has changed since
        # TODO handle it.
        # It could also happen that save validations checks are
        # ok but the db changes and then it fails
        flash[:notice] = "Signed in successfully."
        sign_in(user)
        redirect_to users_path(user)
      else
        flash[:error] = "There is already a user with the same email"
        # TODO ask another email
        session[:omniauth] = omniauth.except('extra')
        render :index
        #redirect_to new_user_registration_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_path
  end

end
