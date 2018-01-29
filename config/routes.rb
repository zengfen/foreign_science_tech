Rails.application.routes.draw do
  get 'user_avatar/edit'

  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users
  resources :spiders do
    member do
      get 'load_edit_form'
    end
    collection do
    end
    resources :spider_tasks do
      member do
        get 'start'
        get 'stop'
      end
      collection do
      end
    end
    resources :spider_cycle_tasks do
      member do
        get 'start'
        get 'stop'
      end
      collection do
      end
    end
  end


  resources :lucene do
    collection do
      get 'index'
      get 'reset'
      get 'remove'
      get 'console'
      get 'test'
      get 'search'
    end
  end

  resources :monitoring do
    collection do
      get 'lucene'
    end
  end

  resources :templates do
    member do
    end

    collection do
      get 'list'
      get 'search'
      get 'load_edit_form'
    end
  end
  resources :user_avatars, :hosts, :media_accounts, :social_accounts, :controllers, :dispatchers, :loaders, :agents, :supervisors, :accounts, :control_templates, :proxies

  resources :tasks do
    member do
      get 'fail_tasks'
      get 'retry_fail_task'
      get 'retry_all_fail_task'
      get 'destroy_fail_task'
    end
    collection do
      get 'get_spider'
    end
  end

  resources :receivers do
    collection do
      get 'set_common'
      get 'set_agent'
    end
  end
  resources :password_resets, only: %i[new create edit update]

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web, at: '/sidekiq'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'archon' && password == 'archon'
  end

  match ':controller(/:action(/:id))(.:format)', via: :all
end
