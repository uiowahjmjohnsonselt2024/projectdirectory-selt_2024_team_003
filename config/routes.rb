Rails.application.routes.draw do

  resources :games do
    collection do
      post 'join', to: 'games#join'
    end
  end

  resources :interactions, param: :game_id do
    post 'attack', on: :member
    post 'use_move', on: :member
  end

  resources :selections, only: [:index]
  patch 'selections/update_archetype', to: 'selections#update_archetype'


  resources :pages do
    post :move, on: :collection
  end

  resources :interactions, only: [] do
    member do
      post :magic_attack
      post :magic_heal
    end
  end

  get 'account', to: 'user#index'
  post 'add_friend', to: 'user#add_friend'
  delete 'remove_friend', to: 'user#remove_friend'
  get 'win_game', to: 'games#win', as: 'win_game'
  delete 'end_game/:game_code', to: 'games#end', as: 'end_game'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy', as: :logout
  post 'signup', to: 'registrations#create'
  get 'pages/grid'
  get 'grid', to: 'pages#grid'
  get 'store', to: 'store#index'
  get 'chat_with_user', to: 'chats#show', as: 'chat_with_user'
  post 'send_message', to: 'chats#create', as: 'send_message'
  patch 'mark_as_read', to: 'chats#mark_as_read', as: 'mark_as_read'
  get 'interaction', to: 'interactions#show'
  post 'attack', to: 'interactions#attack'

  # Route to display the form (text box and button)
  get 'ai_generated_skins/new', to: 'ai_generated_skins#new', as: 'new_ai_generated_skin'
  # Route to handle the form submission and generate the image
  post 'ai_generated_skins/generate', to: 'ai_generated_skins#generate', as: 'generate_ai_generated_skin'


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
  # Set the root of your site to the HomeController's index action
  root 'home#index'

  # Define routes for the login and create actions
  get 'login', to: 'sessions#new', as: 'login_button'
  get 'create', to: 'registrations#new', as: 'create_button'

end
