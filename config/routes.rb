ActionController::Routing::Routes.draw do |map|
  # ROOT
  map.root :controller => 'static_page', :action => 'index'

  # LOGIN/LOGOUT
  map.resource  :user_session
  map.resource  :registration, :only => [:edit, :update]
  map.logout    'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :password_resets, :only => [:create, :edit, :update]

  # PROFILE
  map.resource :profile, :only => [:edit, :update, :disable_tips],
    :member => {:disable_tips => :put}

  # STATIC PAGES
  map.about_page 'about', :controller => 'static_page', :action => 'about'

  map.resources :comments

  # ALL USERS
  map.dashboard 'dashboard', :controller => 'dashboard', :action => :index

  # ADMIN
  map.namespace :admin do |admin|
    admin.resources :requests
    admin.resources :responses, :only => [:index]
    admin.resources :organizations,
      :collection => {:duplicate => :get, :remove_duplicate  => :put,
        :download_template => :get, :create_from_file => :post}
    admin.resources :reports, :only => [:index],
      :collection => { :locations => :get, :district_workplan => :get }
    admin.namespace :reports do |reports|
      reports.resources :detailed, :only => [:index, :show],
        :member => { :generate => :get },
        :collection => { :mark_implementer_splits => :put}
    end
    admin.resources :documents, :as => :files
    admin.resources :currencies, :except => [:show]
    admin.resources :users, :except => [:show],
      :collection => {:create_from_file => :post, :download_template => :get}
    admin.resources :codes,
      :collection => {:create_from_file => :post, :download_template => :get}
    admin.resources :comments
  end

  # ACTIVITY MANAGER
  map.activity_manager_workplan 'activity_manager/workplan', :controller => 'users', :action => :activity_manager_workplan

  # REPORTER USER: DATA ENTRY
  map.resources :responses, :only => [],
    :member => {:review => :get, :submit => :put, :restart => :put,
      :reject => :put, :accept => :put,
      :send_data_response => :put, :approve_all_budgets => :put}

  map.resources :projects, :except => [:show],
    :collection => {:download_template => :get,
      :export_workplan => :get,
      :export => :get,
      :import => :post,
      :import_and_save => :post}

  map.resources :activities, :except => [:index, :show],
    :member => {:sysadmin_approve => :put, :activity_manager_approve => :put}

  map.resources :other_costs, :except => [:index, :show],
    :collection => {:create_from_file => :post, :download_template => :get}

  map.resource :organization, :only => [:edit, :update],
    :collection => { :export => :get }


  map.resources :documents, :as => :files

  map.resources :reports, :only => [:index],
    :collection => {:inputs => :get, :locations => :get}
  map.namespace :reports do |reports|
    reports.resources :activities, :only => [:show],
      :member => {:inputs => :get, :locations => :get}
    reports.resources :projects, :only => [:show],
      :member => { :locations => :get, :inputs => :get }
  end
end
