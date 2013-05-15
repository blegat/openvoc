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

Openvoc::Application.routes.draw do
  resources :authentications, only: [:index, :create, :destroy]
  resources :registrations, only: [:new, :create, :destroy]

  resources :languages, only: [:index, :show] do
    resources :words, only: [:new, :create]
    match 'words' => "words#new"
  end
  resources :words, only: [:show, :destroy] do
    resources :links, only: [:create, :new]
    resources :inclusions, only: [:create]
  end
  resources :links, only: [:create, :new, :show, :destroy]

  root to: 'static_pages#home'
  match '/contact', to: 'static_pages#contact'

  match "/auth/:provider/callback" => "authentications#create"
  match "/signin" => "authentications#index", as: :signin
  match "/signout" => "sessions#destroy", as: :signout
  resources :sessions, only: [:new, :create]
  resources :users, only: [:update, :edit, :new, :show, :create]
  resources :lists, only: [:new, :create, :index, :show] do
    match "/export" => "lists#export", as: :export
    match "/moving" => "lists#moving", as: :moving
    match "/move" => "lists#move", as: :move
    match "/training" => "lists#training", as: :training
    resources :trains, only: [:new, :create] do
      match "/toggle_success" => "trains#toggle_success", as: :toggle_success
    end
    resources :lists, only: [:new, :create]
    resources :words, only: [:destroy]
  end
end
