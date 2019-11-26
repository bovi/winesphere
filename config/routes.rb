Rails.application.routes.draw do
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

  resources :booths do
    resources :thermometers 
    resources :scales
    get 'liter', to: 'booths#liter'
    get 'temp', to: 'booths#temp'
    get 'cups', to: 'booths#cups'
  end
end
