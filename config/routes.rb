Rails.application.routes.draw do

  root 'events#index'

  devise_for :users

  resources :events, shallow: true do
    member do
      get 'vote'
    end

    resources :questions do
      resources :choices
    end
  end

  resources :votes

  get 'questions/:id/publish_question' => 'questions#publish_question', as: :questions_publish

  get 'questions/:id/clear_votes' => 'questions#clear_votes', as: :clear_votes

  get 'enter_poll', to: 'events#parse_event_id', as: :parse_id

  get "*any", via: :all, to: "errors#not_found"

end
