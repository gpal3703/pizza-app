Rails.application.routes.draw do
  resources :orders, only: [:index, :update]
  root to: 'orders#index'
end
