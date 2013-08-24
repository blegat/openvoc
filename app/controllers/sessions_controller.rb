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

class SessionsController < ApplicationController
  before_filter :signed_out_user, only: [:new, :create]

  def new
    # Login with a registration
  end
  def create
    registration = Registration.find_by_email(params[:registration][:email])
    if registration
      if registration.authenticate(params[:registration][:password])
        sign_in registration.user
        redirect_back_or registration.user
      else
        flash.now[:error] = 'Incorrect password'
      end
    else
      flash.now[:error] = 'There is no registration with this email'
    end
    render 'new'
  end

  def destroy
    #session[:user_id] = nil
    sign_out
    redirect_to root_path, :notice => "Signed out!"
  end
end
