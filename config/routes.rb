Rails.application.routes.draw do
  root :to => 'splash_page#index'

  get '/home', :to => 'pages#index', as: :home
  get '/about', :to => 'pages#about', as: :about

  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
