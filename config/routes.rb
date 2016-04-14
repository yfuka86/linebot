Rails.application.routes.draw do
  namespace :api do
    resources :linebot do
      collection do
        post :callback
      end
    end
  end
end
