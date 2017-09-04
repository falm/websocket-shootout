Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  # mount Peek::Railtie => '/peek'
  get '/ws' => 'ws_debugger#show'
end
