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

Rails.application.routes.draw do
  get 'link_vote/new'

  get 'train_fragment/new'

  resources :meanings

  resources :wordsets, controller: :word_sets

  resources :authentications, only: [:index, :create, :destroy]
  resources :registrations, only: [:new, :create, :edit, :update, :destroy]

  resources :languages, only: [:index, :show] do
    resources :words, only: [:new, :create]
    get 'words', to: "words#new"
  end
  resources :words, only: [:show, :destroy] do
    resources :links, only: [:create, :new]
    resources :meaning do
      resources :wordsets, only: [:create], controller: :word_sets
    end
  end
  resources :links, only: [:create, :new, :show, :destroy]

  root to: 'static_pages#home'
  get '/contact', to: 'static_pages#contact'

  get "/auth/:provider/callback", to: "authentications#create"
  get "/signin", to: "authentications#index", as: :signin
  get "/signout", to: "sessions#destroy", as: :signout
  resources :sessions, only: [:new, :create]
  resources :users, only: [:update, :edit, :new, :show, :create]
  resources :trains, only: [:new, :create, :show, :destroy] do
    get "/summary", to: "trains#summary", as: :summary
    get "/finalize", to: "trains#finalize", as: :finalize
  end

  get "/publiclists" => "lists#public", as: :public

  resources :lists, only: [:new, :create, :index, :show, :edit, :destroy, :update] do
    post "/prepare_data" => "lists#prepare_data_to_add", as: :prepare_data_to_add
    post "/add_data" => "lists#add_data", as: :add_data
    get "/exporting" => "lists#exporting", as: :exporting
    get "/export" => "lists#export", as: :export
    get "/moving" => "lists#moving", as: :moving
    post "/move" => "lists#move", as: :move
    get "/import" => "lists#import", as: :import
    get "/upload" => "upload#upload", as: :upload
    match "/save_upload" => "upload#save_upload", via: :post, as: :save_upload
    get "/training" => "lists#training", as: :training
    resources :trains, only: [:new, :create] do
      get "/toggle_success" => "trains#toggle_success", as: :toggle_success
    end
    resources :lists, only: [:new, :create, :edit, :destroy]
    resources :words, only: [:destroy]
  end

  get "/groups/search" => "groups#search", as: :groupsearch

  resources :groups, only: [:new, :create, :index, :show, :edit, :destroy] do
    get "/leave" => "groups#leave"
    get "/manage/general" => "groups#managegeneral"
    patch "manage/general" => "groups#managegeneralpatch"
    get "/manage/members" => "groups#managemembers"
    post "/manage/members/remove" => "groups#managemembersremove"
    get "/add" => "groups#add"
    get "/addpeople" => "groups#addpeople"

    resources :lists, only: [:new, :create, :index, :show, :edit, :destroy] do
      post "/prepare_data" => "lists#prepare_data_to_add", as: :prepare_data_to_add
      post "/add_data" => "lists#add_data", as: :add_data
      get "/exporting" => "lists#exporting", as: :exporting
      get "/export" => "lists#export", as: :export
      get "/moving" => "lists#moving", as: :moving
      post "/move" => "lists#move", as: :move
      get "/import" => "lists#import", as: :import
      get "/upload" => "upload#upload", as: :upload
      match "/save_upload" => "upload#save_upload", via: :post, as: :save_upload
      resources :trains, only: [:new, :create]
      resources :lists, only: [:new, :create, :edit, :destroy]
      resources :words, only: [:destroy]
    end
  end
end
