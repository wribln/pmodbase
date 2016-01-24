Rails.application.routes.draw do

  root 'home#index', as: 'home', format: false

  get  'base/index', as: 'base', format: false
  post 'home/signon', as: 'signon', format: false
  get  'home/signoff', as: 'signoff', format: false

  get  'sfas', to: 'abbr_search#index', format: false
  get  'frqs', to: 'feature_responsibilities#index', format: false
  get  'wrqs', to: 'workflow_responsibilities#index', format: false

  get 'help', to: 'help_pages#show_default', format: false
  get 'help/:title', to: 'help_pages#show', format: false

  resources :abbreviations, path: 'aaas', format: false
  resources :accounts, path: 'anps', format: false
  resources :addresses, path: 'adts', format: false
  get 'cdls/info', to: 'contact_lists#info', as: 'account_list', format: false
  resources :contact_lists, path: 'cdls', format: false, only: [ :index, :show ]
  resources :contact_infos, path: 'ccis', format: false
  resources :country_names, path: 'cncs', format: false
  resources :csr_status_records, path: 'csrs', format: false
  resources :db_change_requests, path: 'acrs', format: false
  get 'dsrs/info', to: 'dsr_status_records#info', as: 'dsr_workflow_info', format: false
  get 'dsrs/stats', to: 'dsr_status_records#stats', as: 'dsr_statistics_index', format: false
  get 'dsrs/:id/stats', to: 'dsr_status_records#stats', as: 'dsr_statistics_detail', format: false
  get 'dsrs/update', to: 'dsr_status_records#update_b_all', as: 'update_dsr_status_records', format: false
  get 'dsrs/:id/new', to: 'dsr_status_records#add', as: 'add_dsr_status_record', format: false
  get 'dsrs/:id/update', to: 'dsr_status_records#update_b_one', as: 'update_dsr_status_record', format: false
  resources :dsr_status_records, path: 'dsrs', format: false
  resources :dsr_doc_groups, path: 'ddgs', format: false
  resources :dsr_progress_rates, path: 'dprs', format: false, only: [ :index, :show, :edit, :update ]
  resources :dsr_submissions, path: 'dsbs', format: false
  resources :features, path: 'fits', format: false
  resources :feature_categories, path: 'fcts', format: false
  resources :glossary_items, path: 'glos', format: false
  resources :groups, path: 'grps', format: false
  resources :group_categories, path: 'gcts', format: false
  get 'hlds/:id/new', to: 'holidays#add', as: 'add_holiday', format: false
  resources :holidays, path: 'hlds', format: false 
  resources :people, path: 'apts', format: false
  resources :phase_codes, path: 'ppcs', format: false
  resource  :profile, format: false, only: [ :show, :edit, :update ]
  resources :programme_activities, path: 'ppas', format: false
  resources :references, path: 'refs', format: false
  resources :region_names, path: 'rncs', format: false
  resources :responsibilities, path: 'rpps', format: false
  resources :rfc_documents, path: 'rcds', format: false
  get 'rsrs/info', to: 'rfc_status_records#info', as: 'rfc_workflow_info', format: false
  get 'rsrs/stats', to: 'rfc_status_records#stats', as: 'rfc_status_info', format: false
  resources :rfc_status_records, path: 'rsrs', format: false
  resources :siemens_phases, path: 'spcs', format: false
  resources :standards_bodies, path: 'ssos', format: false
  resources :statistics, path: 'sdhs', format: false, only: :index
  resources :submission_groups, path: 'sgps', format: false
  resources :web_links, path: 'wlks', format: false
  resources :all_tia_lists, path: 'atls', format: false
  resources :my_tia_lists, path: 'mtls', format: false do
    resources :our_tia_items, path: 'otis', format: false, shallow: true
    resources :our_tia_members, path: 'otms', format: false, shallow: true
  end
  get 'mtis/:id/info', to: 'my_tia_items#info', as: 'my_tia_item_info', format: false
  get 'otis/:id/info', to: 'our_tia_items#info', as: 'our_tia_item_info', format: false
  resources :my_tia_items, path: 'mtis', format: false
  resources :unit_names, path: 'uncs', format: false
  resources :my_change_requests, path: 'mcrs', format: false
  get 'mcrs/new/:feature_id/(:detail)' => 'my_change_requests#new', as: :add_my_change_request, format: false 

  end
