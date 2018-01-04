Rails.application.routes.draw do

  get 'user_avatar/edit'

  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to:'templates#list'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users
  resources :spiders do
    member do
      get 'load_edit_form'
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
  resources :user_avatars
  resources :password_resets,     only: [:new, :create, :edit, :update]
  match ':controller(/:action(/:id))(.:format)',via: :all
end
