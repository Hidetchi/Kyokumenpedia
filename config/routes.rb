Rails.application.routes.draw do
  get 'pages/help'
  get 'pages/about'
  get 'pages/terms'
  devise_for :users
  post 'users/watch'
  post 'users/unwatch'
  post 'users/follow'
  post 'users/unfollow'
  resources :users, :only => [:index, :show]
  get 'positions/search' => 'positions#search'
  get 'positions/list/:mode' => 'positions#list'
  get 'positions/:sfen1/:sfen2/:sfen3/:sfen4/:sfen5/:sfen6/:sfen7/:sfen8/:sfen9' => 'positions#show'
  post 'positions/show' => 'positions#show'
  get 'positions/:id/edit' => 'positions#edit'
  get 'positions/:id/discussion' => 'discussions#index'
  get 'positions/:id/:moves' => 'positions#show'
  resources :positions, :only => [:show]
  get 'newkifu' => 'games#create'
  post 'wikiposts/create' => 'wikiposts#create'
  get 'wikiposts/list_pos/:position_id' => 'wikiposts#index'
  get 'wikiposts/list_usr/:user_id' => 'wikiposts#index'
  resources :wikiposts, :only => [:index, :show]
  get 'discussions/index'
  post 'discussions/create'
  root :to => 'positions#show', :sfen => 'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b -'
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
