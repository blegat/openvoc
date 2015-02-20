## BEGIN LICENSE
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

class CreateMeanings < ActiveRecord::Migration
  def change
    remove_index :links, :word1_id
    remove_index :links, :word2_id
    change_table :links do |t|
      t.remove :word1_id
      t.remove :word2_id
    end

    create_table :meanings do |t|
      t.timestamps
    end

    change_table :links do |t|
      t.references :word
      t.references :meaning
    end
    add_index :links, :word_id
    add_index :links, :meaning_id

    # Why did I add it in the first place ?
    change_table :words do |t|
      t.remove :link_id
    end
  end
end
