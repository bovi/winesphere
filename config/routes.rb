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
  end

  resources :booths do
    resources :scales
  end
end
