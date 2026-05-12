Rails.application.routes.draw do
  root "events#index"
  resources :events, only: [:index]

  # Health check endpoints kept by default
  get "up" => "rails/health#show", as: :rails_health_check
end