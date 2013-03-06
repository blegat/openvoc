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

module ApplicationHelper

  # Returns the full title of a page
  def full_title(page_title)
    base_title = "Openvoc"
    if page_title.empty?
      "#{base_title}"
    else
      "#{base_title} - #{page_title}"
    end
  end

  def flash_errors(object)
    unless object.errors.empty?
      flash.now[:error] = object.errors.full_messages.to_sentence
    end
  end

end
