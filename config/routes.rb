Rails.application.routes.draw do
  post 'api/kifu_post' => 'games#create'

  get 'pages/help'
  get 'pages/about'
  get 'pages/terms'
  get 'pages/personal'

  devise_for :users, controllers: { registrations: 'users/registrations' }
  post 'users/watch'
  post 'users/unwatch'
  post 'users/follow'
  post 'users/unfollow'
  post 'users/like'
  resources :users, :only => [:index, :show, :update] do
    collection do
      get 'ranking'
      get 'mypage'
    end
    get 'followers', on: :member
    resources :wikiposts, :only => [:index]
  end

  resources :positions, :only => [:show] do
    collection do
      get 'search'
      post 'keyword'
      post 'show'
      get 'start/:handicap_id' => 'positions#start', handicap_id: /\d/
      get 'list/:mode' => 'positions#list', mode: /[a-z]+/
      get ':sfen1/:sfen2/:sfen3/:sfen4/:sfen5/:sfen6/:sfen7/:sfen8/:sfen9' => 'positions#show', sfen1: /[1-9krbgsnlp\+]+/i, sfen9: /[1-9krbgsnlp\+]+%20[bw]%20[0-9rbgsnlp\-]+/i
      get ':sfen' => 'positions#show', sfen: /([1-9KRBGSNLPkrbgsnlp\+]+\/){8}[1-9krbgsnlp\+]+\s[bw]\s[0-9rbgsnlp\-]+/i
    end
    member do
      get 'statistics/:category' => 'positions#statistics', category: /\d+/, as: :statistics
      get 'edit'
      get 'export'
      get 'privilege'
      post 'post'
      post 'pickup'
      post 'set_main'
      get ':moves' => 'positions#show', moves: /([\+\-]\d{4}[A-Z]{2})+/, as: :moves
    end
    resources :wikiposts, :only => [:index]
    resources :discussions, :only => [:index, :create] do
      get 'post', on: :collection
    end
    resources :strategies, :only => [:create, :update]
  end

  resources :wikiposts, :only => [:index, :show]
  get 'wikiposts/:id/likers' => 'wikiposts#likers'

  root :to => 'activities#index'
  
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get '*path', to: 'application#routing_error'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
