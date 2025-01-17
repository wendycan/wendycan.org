LeavesCom::Application.routes.draw do

  root to: "home#index"

  get 'home/index'
  get 'home/sales'
  get 'home/summary_2015'

  get 'projects/stars', :path => 'stars'
  get 'info/profile'
  get 'data/companies'
  get 'data/investevents'
  get 'tour/index'
  get 'tour/show' #, :layout => 'tour'

  get 'tools/index'
  get 'tools/ecg'
  get 'tools/audio'
  get 'tools/capture'

  get 'todos/index'
  get 'todos/show'

  get 'bills/index'

  post 'tools/upload'

  resources :leaves, only: [:index, :show]
  resources :projects, only: [:index, :show]

  devise_for :users

  mount Leaves::Api => '/'
  mount Todos::Api => '/api'

  get '/.well-known/acme-challenge/:id' => 'pages#letsencrypt'

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
