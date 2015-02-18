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

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

	describe "full_title" do
		it "should include the page title" do
			expect(full_title("foo")).to match /foo/
		end

		it "should include the base title" do
			expect(full_title("foo")).to match /^Openvoc/
		end

		it "should not include a bar for the home page" do
			expect(full_title("")).not_to match /-/
		end
	end
end
