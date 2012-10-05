Hrt::Application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  match 'users/sign_out' => 'static_page#sign_out'
  resources :invitations, only: [:edit, :update]

  root to: 'static_page#index'
  resource :profile, only: [:disable_tips] do
    member do
      put :disable_tips
    end
  end
  match 'about' => 'static_page#about', as: :about_page
  resources :comments, :only => [:edit, :create, :update, :destroy]
  match 'dashboard' => 'dashboard#index', as: :dashboard
  namespace :admin do
    resources :requests
    resources :responses, only: [:index, :new, :create, :destroy] do
      collection do
        get :export
      end
    end
    resources :organizations do
      collection do
        get :duplicate
        put :remove_duplicate
        get :download_template
        post :create_from_file
      end
    end
    resources :reports, only: [:index] do
      collection do
        get :locations
        get :district_workplan
        get :funders
        get :reporters
      end
    end
    namespace :reports do
      resources :detailed, only: [:index, :show] do
        collection do
          put :mark_double_counts
        end
        member do
          get :generate
        end
      end
    end
    resources :documents, path: 'files'
    resources :currencies, except: [:show]
    resources :users, except: [:show] do
      collection do
        post :create_from_file
        get :download_template
      end
    end
    resources :beneficiaries, only: [:index, :edit, :update]
    resources :locations, only: [:index, :edit, :update]
    resources :codes, only: [:index, :edit, :update] do
      collection do
        post :create_from_file
        get :download_template
      end
    end
  end

  resources :workplans  do
    collection do
      get :download
      get :generate
    end
  end

  resources :responses, :only => [] do
    member do
      get :review
      put :submit
      put :send_data_response
      get :reject
      get :accept
      get :generate_overview
      get :download_overview
    end
  end
  resources :projects, except: [:show] do
    collection do
      get :download_template
      get :export_workplan
      get :export
      post :import
    end
  end
  resources :activities, except: [:index, :show]
  resources :other_costs, except: [:index, :show] do
    collection do
      post :create_from_file
      get :download_template
    end
  end
  resources :organizations, only: [:index, :edit, :update] do
    collection do
      get :export
    end
  end
  resources :documents
  resources :reports, only: [:index] do
    collection do
      get :inputs
      get :locations
      get :projects
    end
  end

  namespace :reports do
    resources :activities, only: [:show] do
      member do
        get :implementers
        get :inputs
        get :locations
      end
    end
    resources :projects, only: [:show] do
      member do
        get :activities
        get :locations
        get :inputs
      end
    end
  end
end
