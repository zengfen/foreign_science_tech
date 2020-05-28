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
      get 'start'
      get 'stop'
    end
    collection do
    end



    # resources :spider_tasks do
    #   member do
    #     get 'start'
    #     get 'stop'
    #     get 'output'
    #     get 'dp_tags'
    #     get 'download'
    #   end
    #   collection do
    #     get 'download'
    #
    #   end
    # end

    # resources :spider_cycle_tasks do
    #   member do
    #     get 'start'
    #     get 'stop'
    #   end
    #   collection do
    #   end
    # end
  end

  resources :spider_tasks do
    member do
      get 'fail_tasks'
    end
    collection do
      get 'show_keyword'
    end
  end


  resources :t_sk_job_instances do
    member do
      # get :research
      get :start_task
      get :stop_task
    end
    collection do
      # post :send_medium
      # get :review
      # get :update_news_data
      # get :media_authorize
      # get :set_freq
      # post :update_freq
    end
  end

  resources :t_log_spider do
    member do

    end
    collection do

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
