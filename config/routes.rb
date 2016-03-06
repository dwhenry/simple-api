Rails.application.routes.draw do
  # resources :users

  post '/register' => 'users#create'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#delete'

  resources :games
  resources :actions

  resources :admin do
    collection { get :reset }
  end

  root 'main#index'
end
