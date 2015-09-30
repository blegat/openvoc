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
  # Nested parents (see http://m.onkey.org/nested-layouts-in-rails-3)
  def parent_layout(layout)
    @view_flow.set(:layout ,output_buffer)
    self.output_buffer = render(file: "layouts/#{layout}")
  end

  # Returns the full title of a page
  def full_title(page_title)
    base_title = "Openvoc"
    if page_title.empty?
      "#{base_title}"
    else
      "#{base_title} - #{page_title}"
    end
  end

  def flash_errors(object, now = true)
    unless object.errors.empty?
      if now
        flash.now[:danger] = object.errors.full_messages.to_sentence
      else
        flash[:danger] = object.errors.full_messages.to_sentence
      end
    end
  end

  def link_to_bug_tracker(message)
    link_to message, 'https://github.com/blegat/openvoc/issues'
  end

  def link_to_mailing_list(message)
    link_to message, 'mailto:openvoc@googlegroups.com'
  end

  def bootstrap_form_for(subject, url, legend, &block)
    form_for(subject, url: url) do |f|
      block.call(f)
    end
  end
  def flatten_hash(hash = params, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += "[]" if v.is_a?(Array)
        flat_hash[key] = v
      end
    end
    
    flat_hash
  end
  
  def flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup 
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end
  
  def hash_as_hidden_fields(hash = params)
    hidden_fields = []
    flatten_hash(hash).each do |name, value|
      value = [value] if !value.is_a?(Array)
      value.each do |v|
        hidden_fields << hidden_field_tag(name, v.to_s, :id => nil)          
      end
    end
    hidden_fields.join("\n")
  end
  
  def hash_to_hidden_fields(hash)
    query_string = Rack::Utils.build_nested_query(hash)
    pairs        = query_string.split(Rack::Utils::DEFAULT_SEP)

    tags = pairs.map do |pair|
      key, value = pair.split('=', 2).map { |str| Rack::Utils.unescape(str) }
      hidden_field_tag(key, value)
    end

    tags.join("\n").html_safe
  end
  
end
