Rails.application.routes.draw do

  root 'home#index', as: 'home', format: false

  get  'base/index', as: 'base', format: false
  post 'home/signon', as: 'signon', format: false
  get  'home/signoff', as: 'signoff', format: false

  get  'sfa', to: 'abbr_search#index', format: false
  get  'scs', to: 's_code_search#index', format: false
  get  'acs', to: 'a_code_search#index', format: false
  get  'frq', to: 'feature_responsibilities#index', format: false
  get  'wrq', to: 'workflow_responsibilities#index', format: false

  get 'help', to: 'help_pages#show_default', format: false
  get 'help/:title', to: 'help_pages#show', format: false

  resources :abbreviations, path: 'aaa', format: false
  resources :accounts, path: 'anp', format: false
  resources :addresses, path: 'adt', format: false
  get 'cdl/info', to: 'contact_lists#info', as: 'account_list', format: false
  resources :contact_lists, path: 'cdl', format: false, only: [ :index, :show ]
  resources :contact_infos, path: 'cci', format: false
  resources :country_names, path: 'cnc', format: false
  resources :csr_status_records, path: 'csr', format: false
  resources :db_change_requests, path: 'acr', format: false
  get 'dsr/info', to: 'dsr_status_records#info', as: 'dsr_workflow_info', format: false
  get 'dsr/stats', to: 'dsr_status_records#stats', as: 'dsr_statistics_index', format: false
  get 'dsr/:id/stats', to: 'dsr_status_records#stats', as: 'dsr_statistics_detail', format: false
  get 'dsr/update', to: 'dsr_status_records#update_b_all', as: 'update_dsr_status_records', format: false
  get 'dsr/:id/new', to: 'dsr_status_records#add', as: 'add_dsr_status_record', format: false
  get 'dsr/:id/update', to: 'dsr_status_records#update_b_one', as: 'update_dsr_status_record', format: false
  resources :dcc_codes, path: 'sc2', format: false
  resources :dsr_status_records, path: 'dsr', format: false
  resources :dsr_doc_groups, path: 'ddg', format: false
  resources :dsr_progress_rates, path: 'dpr', format: false, only: [ :index, :show, :edit, :update ]
  resources :dsr_submissions, path: 'dsb', format: false
  resources :features, path: 'fit', format: false
  resources :feature_categories, path: 'fct', format: false
  resources :function_codes, path: 'scf', format: false
  resources :glossary_items, path: 'glo', format: false
  resources :groups, path: 'grp', format: false
  resources :group_categories, path: 'gct', format: false
  resources :hashtags, path: 'htg', format: false
  get 'hld/:id/new', to: 'holidays#add', as: 'add_holiday', format: false
  resources :holidays, path: 'hld', format: false 
  resources :location_codes, path: 'scl', format: false
  resources :network_lines, path: 'nln', format: false
  resources :network_stations, path: 'nst', format: false
  resources :network_stops, path: 'nso', format: false
  resources :people, path: 'apt', format: false
  resources :phase_codes, path: 'ppc', format: false
  resources :product_codes, path: 'scp', format: false
  resource  :profile, format: false, only: [ :show, :edit, :update ]
  resources :programme_activities, path: 'ppa', format: false
  resources :references, path: 'ref', format: false
  resources :region_names, path: 'rnc', format: false
  resources :responsibilities, path: 'rpp', format: false
  resources :rfc_documents, path: 'rcd', format: false
  get 'rsr/info', to: 'rfc_status_records#info', as: 'rfc_workflow_info', format: false
  get 'rsr/stats', to: 'rfc_status_records#stats', as: 'rfc_status_info', format: false
  resources :rfc_status_records, path: 'rsr', format: false
  resources :s_document_logs, path: 'sdl', format: false
  resources :a_document_logs, path: 'adl', format: false
  resources :service_codes, path: 'scv', format: false
  resources :siemens_phases, path: 'spc', format: false
  resources :standards_bodies, path: 'sso', format: false
  resources :statistics, path: 'sdh', format: false, only: :index
  resources :submission_groups, path: 'sgp', format: false
  resources :web_links, path: 'wlk', format: false
  resources :all_tia_lists, path: 'atl', format: false
  resources :my_tia_lists, path: 'mtl', format: false do
    resources :our_tia_items, path: 'oti', format: false, shallow: true
    resources :our_tia_members, path: 'otm', format: false, shallow: true
  end
  get 'mti/:id/info', to: 'my_tia_items#info', as: 'my_tia_item_info', format: false
  get 'oti/:id/info', to: 'our_tia_items#info', as: 'our_tia_item_info', format: false
  resources :my_tia_items, path: 'mti', format: false
  resources :unit_names, path: 'unc', format: false
  resources :my_change_requests, path: 'mcr', format: false
  get 'mcr/new/:feature_id/(:detail)' => 'my_change_requests#new', as: :add_my_change_request, format: false 
  # rarely used ...
  resources :a1_codes, path: 'a1c', format: false
  resources :a2_codes, path: 'a2c', format: false
  resources :a3_codes, path: 'a3c', format: false
  resources :a4_codes, path: 'a4c', format: false
  resources :a5_codes, path: 'a5c', format: false
  resources :a6_codes, path: 'a6c', format: false
  resources :a7_codes, path: 'a7c', format: false
  resources :a8_codes, path: 'a8c', format: false
  end
