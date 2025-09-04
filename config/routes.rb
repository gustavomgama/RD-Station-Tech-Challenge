require 'sidekiq/web'

Rails.application.routes.draw do
  root "rails/health#show"

  resources :products

  get '/cart', to: 'carts#show'
  post '/cart', to: 'carts#create'
  post '/cart/add_item', to: 'carts#update'
  delete '/cart/:product_id', to: 'carts#destroy'

  mount Sidekiq::Web => '/sidekiq'
  get "up" => "rails/health#show", as: :rails_health_check
end
