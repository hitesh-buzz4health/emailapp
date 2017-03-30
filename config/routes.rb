Emailapp::Application.routes.draw do
  resources :histories

  resources :reports





  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # mount Browserlog::Engine => '/logs'
  get "/ultrasound_cases" => 'cases#ultrasoundcases'
  get "/radiopedia_fast" => 'cases#radiopedia_fast' 
  get "/radiopedia" => 'cases#radiopedia'
  post "/finish_campaign" => 'emails#finish_campaign'
  post "mails/post" => 'mails#post'
  post "groups/post" => 'groups#post'

  get '/unsubscribe' => 'unsubscribes#new'
  get '/groups' => 'groups#index'
  get '/unsubscribe/create' => 'unsubscribes#create', :method => :post
  post "/search_by_email" => 'references#search'
  post "/search_by_name" => 'references#search'
  post "/send_email" => 'emails#send_email'
  post "/feeds" => 'feeds#create'

  get "/filter_by_reference_specialization" => 'references#filter_by_reference_specialization'

  get "/filter_by_type" => 'references#filter_by_reference_type'
  get "/mails" => 'mails#index'
  get "/mails_using_gmail_api" => 'gmail_mailer#index'
  post "/mails_using_gmail_api/post" => 'gmail_mailer#post' 

  get "/logs" => "gmail_mailer#log"
  resources :references 
   root 'gmail_mailer#index'



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
