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

include ApplicationHelper

def cookie_jar
     Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
end

def sign_in(user)
  #visit signin_path
  #fill_in "Email",    with: user.email
  #fill_in "Password", with: user.password
  #click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookie_jar[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end
