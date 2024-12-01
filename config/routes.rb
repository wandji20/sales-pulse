Rails.application.routes.draw do
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "account", to: "users#edit"

  resources :users, except: :edit do
    put :preferences, on: :member
  end

  resources :notifications, only: :index

  resources :products
  resources :products, only: [] do
    resources :variants, except: :index
    resources :variants, only: [] do
      resources :stocks, only: [] do
        get :edit, on: :collection
        put :update, on: :collection
      end
    end
  end

  resources :passwords, param: :token

  resources :records, except: :show
  resources :records, only: [] do
    put :revert, on: :member
    collection do
      get :search_variants
      get :search_customers
      get :search_service_items
    end
  end

  # Dashboard
  get "/dashboard", to: "dashboard#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "records#index"
end
