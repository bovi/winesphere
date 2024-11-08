Rails.application.routes.draw do
  root to: 'booths#overview'
  resources :weights
  resources :temperatures
  resources :thermometers
  resources :scales do
    get 'offset', to: 'scales#offset'
    get 'rescale', to: 'scales#rescale_all_values'
  end
  resources :booths

  post '/new_temperature', to: 'temperatures#new_entry'
  post '/new_weight', to: 'weights#new_entry'
  get '/purge_all_now', to: 'booths#purge'
  get '/kitchen', to: 'booths#kitchen'
  get '/admin', to: 'booths#show_admin'

  resources :booths do
    resources :thermometers do
      get 'admin', to: 'thermometers#show_admin'
    end
    resources :scales do 
      get 'admin', to: 'scales#show_admin'
    end
    get 'liter', to: 'booths#liter'
    get 'temp', to: 'booths#temp'
    get 'cups', to: 'booths#cups'
    get 'empty', to: 'booths#empty'
  end
end
