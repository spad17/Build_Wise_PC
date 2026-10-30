Rails.application.routes.draw do
  root "home#index"

  get "/signup", to: "users#new", as: :signup
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get "/my-builds", to: "builds#index", as: :my_builds
  resources :builds, only: %i[new create show destroy] do
    member do
      patch :optimize
      patch :replace_component
    end
  end
  resources :components, only: %i[index show] do
    resources :reviews, only: %i[create update destroy]
  end
  get "/ui-kit", to: "ui_kit#index", as: :ui_kit
end
