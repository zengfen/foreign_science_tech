Rails.application.routes.draw do


  get 'user_avatar/edit'

  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to:'home#index'
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
    end
    collection do
    end
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
  resources :user_avatars,:tasks,:hosts,:media_accounts,:social_accounts, :controllers, :dispatchers, :receivers, :loaders

  resources :receivers do
    member do
      get :set_common
      get :set_agent
    end
  end
  resources :password_resets,     only: [:new, :create, :edit, :update]
  match ':controller(/:action(/:id))(.:format)',via: :all
end
