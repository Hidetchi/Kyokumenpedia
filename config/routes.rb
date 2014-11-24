Rails.application.routes.draw do
  post 'api/kifu_post' => 'games#create'
  get 'pages/help'
  get 'pages/about'
  get 'pages/terms'
  devise_for :users, controllers: { registrations: 'users/registrations' }
  post 'users/watch'
  post 'users/unwatch'
  post 'users/follow'
  post 'users/unfollow'
  post 'users/like'
  get 'users/mypage'
  get 'users/ranking'
  get 'users/:id/followers' => 'users#followers'
  resources :users, :only => [:index, :show, :update]
  get 'positions/start'
  get 'positions/search'
  post 'positions/keyword'
  get 'positions/list/:mode' => 'positions#list'
  get 'positions/:sfen1/:sfen2/:sfen3/:sfen4/:sfen5/:sfen6/:sfen7/:sfen8/:sfen9' => 'positions#show'
  post 'positions/show' => 'positions#show'
  get 'positions/:id/statistics' => 'positions#statistics'
  get 'positions/:id/edit' => 'positions#edit'
  get 'positions/:id/discussions' => 'discussions#index'
  get 'positions/:id/post' => 'discussions#post'
  get 'positions/:id/export' => 'positions#export'
  get 'positions/:id/:moves' => 'positions#show'
  resources :positions, :only => [:show]
  get 'newkifu' => 'games#create'
  post 'wikiposts/create' => 'wikiposts#create'
  get 'wikiposts/list_pos/:position_id' => 'wikiposts#index'
  get 'wikiposts/list_usr/:user_id' => 'wikiposts#index'
  get 'wikiposts/:id/likers' => 'wikiposts#likers'
  resources :wikiposts, :only => [:index, :show]
  get 'discussions/index'
  post 'discussions/create'
  root :to => 'activities#index'
  
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
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
