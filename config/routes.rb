# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get 'projects_status', to: 'projects_status#index'
  get 'incidents', to: 'incidents#index'
  post 'flows', to: 'flow#create'

  namespace 'authentication' do
    post 'github', to: 'github#create'
    get 'github', to: 'github#index'
  end

  resources :servers
  resources :open_pull_requests, only: :index
  resources :server_incidents_report, only: :show
  resources :projects, only: :show

  root 'application#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
