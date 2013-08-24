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

Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem'
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  provider :openid, store: OpenID::Store::Filesystem.new('/tmp')
  provider :developer unless Rails.env.production?
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  #provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  #provider :identity,
    #on_failed_registration: IdentitiesController.action(:new)
    #form: lambda { |env| SessionsController.action(:new).call(env) }#, on_failed_registration: lambda { |env|
    #IdentitiesController.action(:new).call(env)
  #}
  #provider :identity,
    #form: lambda { |env| SessionsController.action(:new).call(env) },
    #on_failed_registration:
    #lambda { |env| IdentitiesController.action(:new).call(env) }
end
