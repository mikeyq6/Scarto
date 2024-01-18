Rails.application.routes.draw do
  # root 'game#index'
  
  # get "/game", to: "game#index"
  # get "/game/new", to: "game#new"
  # get "/game/:id", to: "game#show"
  # post "/game", to: "game#create"  # usually a submitted form
  # get "/game/:id/edit", to: "game#edit"
  # put "/game/:id", to: "game#update" # usually a submitted form
  # delete "/game/:id", to: "game#destroy"

  resources :games
end
