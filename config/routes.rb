# frozen_string_literal: true

Rails.application.routes.draw do
  post 'logger', to: 'logger_endpoint#create'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
