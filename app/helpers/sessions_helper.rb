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

module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] =  user.remember_token
    #session[:user_id] =  user.id
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user?(user)
    user == current_user
  end

  def current_user
    #if cookies[:remember_token].nil?
      #nil
    #else
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
    #end
    #@current_user ||= User.find_by_id(session[:user_id])
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
    #@current_user ||= User.find_by_id(session[:user_id])
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, flash: { info: "Please sign in." }
    end
  end
  def signed_out_user
    if signed_in?
      redirect_to root_path, flash: { info: "Please sign out first." }
    end
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
    #session.delete(:user_id)
  end

  def redirect_back_or(default)
    return_to = session[:return_to]
    # FIXME maybe not delete it if redirect_to fails
    session.delete(:return_to)
    redirect_to(return_to || default) and return true
  end

  def store_location
    session[:return_to] = request.fullpath
  end
end
