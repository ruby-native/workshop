Rails.application.routes.draw do
  resource  :session
  resources :passwords, param: :token
  resource  :registration, only: [ :new, :create ]

  # Tabs
  root "dashboard#show"
  get "summary",  to: "summary#show"
  get "settings", to: "settings#show"

  # Logging expenses
  resources :expenses, only: [ :new, :create, :edit, :update, :destroy ]

  # Budget categories
  resources :categories, except: [ :show ]

  # Households & sharing a budget
  resources :households, only: [ :new, :create, :edit, :update ] do
    member do
      post :switch
      post :regenerate_invite
    end
  end
  resource  :join, only: [ :new, :create ]
  resources :memberships, only: [ :destroy ]

  # Account
  resource :profile, only: [ :edit, :update ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
