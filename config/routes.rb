Rails.application.routes.draw do
  root "events#index"

  resources :events, only: [:index] do
    resources :votes, only: [:create]
  end

  delete "sign_out", to: "sessions#destroy", as: :sign_out


  get "up" => "rails/health#show", as: :rails_health_check
end