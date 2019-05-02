# frozen_string_literal: true

Rails.application.routes.draw do
  scope "#{ENV['PATH_PREFIX']}/#{ENV['APP_NAME']}" do
    mount Rswag::Api::Engine => '/api-docs'
    mount Rswag::Ui::Engine => 'api-docs'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    resources :apps, :only => %i[index show] do
      collection do
        post 'register', to: 'app_registration#create'
      end
    end

    resources :endpoints, :except => %(edit new) do
      resource :filter, :only => %(show)
      member do
        post 'test', to: 'endpoints#test'
      end
    end
  end

  match '*path', to: 'fallback#routing_error', via: :all
end
