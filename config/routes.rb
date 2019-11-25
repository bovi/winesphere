Rails.application.routes.draw do
  resources :weights
  resources :temperatures
  resources :thermometers
  resources :scales
  resources :booths

  #post '/new_temperature', to: 'temperatures#create'
  post '/new_temperature', to: 'temperatures#new_entry'

  resources :booths do
    resources :thermometers 
    resources :scales
    get 'liter', to: 'booths#liter'
    get 'temp', to: 'booths#temp'
    get 'cups', to: 'booths#cups'
  end
end
