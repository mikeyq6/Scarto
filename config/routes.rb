Rails.application.routes.draw do
  # root 'game#index'
  
  # get "/game", to: "game#index"
  # get "/game/new", to: "game#new"
  # get "/game/:id", to: "game#show"
  # post "/game", to: "game#create"  # usually a submitted form
  # get "/game/:id/edit", to: "game#edit"
  # put "/game/:id", to: "game#update" # usually a submitted form
  # delete "/game/:id", to: "game#destroy"

  get "/play/:id", to: "playgame#play"
  post "/play/:id/swap", to: "playgame#swap"
  get "/play/:id/swap_done", to: "playgame#swap_done"
  post "/play/:id/play_card", to: "playgame#play_card"

  resources :games
end
