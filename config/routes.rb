Rails.application.routes.draw do
  get 'user_avatar/edit'

  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'spiders#index'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :password_resets, only: %i[new create edit update]
  resources :users



  resources :home do

  end

  resources :spiders do
    member do
      get 'load_edit_form'
      post 'start_cycle_task'
      post 'stop_cycle_task'
    end
  end

  resources :spider_tasks do
    member do
      get 'fail_tasks'
      post 'start_task'
      post 'stop_task'
    end
  end

  resources :dashboards
  resources :data_centers

  resources :test do
    collection do
      get 'list'
      get 'item'

    end
  end

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web, at: '/sidekiq'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'archon' && password == 'archon'
  end

  match ':controller(/:action(/:id))(.:format)', via: :all
end
