Rails.application.routes.draw do
  root 'pages#index'
  resources :pages

  # git dump-http protocol:
  get "/info/refs"          => "git_clone#refs"
  get "/HEAD"               => "git_clone#head"
  get "/objects/info/packs" => "git_clone#packs"
  get "/objects/pack/:file" => "git_clone#pack_file"
  get "/objects/*name"      => "git_clone#object"
end
