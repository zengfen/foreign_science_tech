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
        get 'output'
        get 'dp_tags'
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
  resources :settings do
    collection do
      get 'load_edit_form'
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
  resources :user_avatars, :social_accounts, :controllers, :dispatchers, :loaders, :agents, :supervisors, :control_templates, :proxies, :social_account_monitors, :base_spiders

  resources :services do
    collection do
      get 'receiver'
      get 'receiver_details'
      get 'loader'
      get 'loader_details'
      get 'dumper'
      get 'dumper_details'
      get 'counters'
    end
  end

  resources :hosts do
    collection do
      get 'service_errors'
      get 'service_counters'
      get 'receiver_trend'
      get 'loader_kafka_trend'
      get 'loader_es_trend'
      get 'host_task_counters'
      get 'block_ips'
      get 'del_block_ip'
    end
  end

  resources :accounts do
    collection do
      get 'ip_list'
    end
  end

  resources :media_accounts do
    collection do
      get 'test'
      get 'search'
    end
  end

  resources :tasks do
    member do
      get 'fail_tasks'
      get 'retry_fail_task'
      get 'retry_all_fail_task'
      get 'destroy_fail_task'
      get 'results_trend'
    end
    collection do
      get 'show_keyword'
      get 'get_spider'
      get 'gc'
    end
  end

  resources :receivers do
    collection do
      get 'set_common'
      get 'set_agent'
    end
  end
  resources :password_resets, only: %i[new create edit update]


  resources :data_centers do
    collection do
      get 'record_details'
    end
  end

  resources :information_statistics do
    collection do
      get :update_statistic
      get :update_today_statistic
      get :govern
      get :all_info
      get :switch_status
      post :remark
      post :update_data_source
      post :hav_infos
      get :download_daily_news_count
    end

    member do 
      get :detail
    end
  end

  resources :domain_data do
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
