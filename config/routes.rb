# frozen_string_literal: true

Rails.application.routes.draw do
  post 'logger', to: 'logger_endpoint#create'

  scope '/r/insights/platform/notifications/' do
    mount Rswag::Api::Engine => '/api-docs'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    resources :apps, :only => %i[index show]
    resources :endpoints, :except => %[edit new]
  end
end
