Rails.application.routes.draw do

  # action name must be of a specific format:
  # - must consist of either a standard action name
  # - or a name with a standard action name prefix and 
  #   with a button_label suffix
  # - parts must be separated by _

  defaults format: false do

  root 'home#index', as: 'home'

  get  'base/index', as: 'base'
  post 'home/signon', as: 'signon'
  get  'home/signoff', as: 'signoff'

  get  'sfa', to: 'abbr_search#index'
  get  'scs', to: 's_code_search#index'
  get  'acs', to: 'a_code_search#index'
  get  'frq', to: 'feature_responsibilities#index'
  get  'wrq', to: 'workflow_responsibilities#index'

  get 'help', to: 'help_pages#show_default'
  get 'help/:title', to: 'help_pages#show', as: 'help_page'

  resources :abbreviations, path: 'aaa'
  resources :accounts, path: 'anp'
  resources :addresses, path: 'adt'
  resources :cfr_relationships, path: 'cfs'
  resources :cfr_file_types, path: 'cft'
  resources :cfr_location_types, path: 'cfu'
  get 'cfr/:id/all', to: 'cfr_records#show_all', as: 'cfr_record_details'
  resources :cfr_records, path: 'cfr'
  get 'cdl/info', to: 'contact_lists#info', as: 'account_list'
  resources :contact_lists, path: 'cdl', only: [ :index, :show ]
  resources :contact_infos, path: 'cci'
  resources :country_names, path: 'cnc'
  resources :csr_status_records, path: 'csr'
  resources :db_change_requests, path: 'acr'
  resources :dcc_codes, path: 'sc2'
  get 'dsr/info', to: 'dsr_status_records#info_workflow', as: 'dsr_workflow_info'
  get 'dsr/stats', to: 'dsr_status_records#stats', as: 'dsr_statistics_index'
  get 'dsr/:id/stats', to: 'dsr_status_records#stats', as: 'dsr_statistics_detail'
  get 'dsr/update', to: 'dsr_status_records#update_b_all', as: 'update_dsr_status_records'
  get 'dsr/:id/new', to: 'dsr_status_records#add', as: 'add_dsr_status_record'
  get 'dsr/:id/update', to: 'dsr_status_records#update_b_one', as: 'update_dsr_status_record'
  resources :dsr_status_records, path: 'dsr'
  resources :dsr_doc_groups, path: 'ddg'
  resources :dsr_progress_rates, path: 'dpr', only: [ :index, :show, :edit, :update ]
  resources :dsr_submissions, path: 'dsb'
  resources :features, path: 'fit'
  resources :feature_categories, path: 'fct'
  resources :function_codes, path: 'scf'
  resources :glossary_items, path: 'glo'
  resources :groups, path: 'grp'
  resources :group_categories, path: 'gct'
  resources :hashtags, path: 'htg'
  get 'hld/:id/new', to: 'holidays#add', as: 'add_holiday'
  resources :holidays, path: 'hld'
  get 'isa',              to: 'isr_agreements#index',         as: 'isr_agreements'
  get 'isa/stats',        to: 'isr_agreements#show_stats',    as: 'isr_statistics'
  get 'isr/info',         to: 'isr_interfaces#info_workflow', as: 'isr_workflow_info'
  get 'isr/:id/all',      to: 'isr_interfaces#show_all',      as: 'isr_interface_details'
  get 'isr/ia/:id',       to: 'isr_interfaces#show_ia',       as: 'isr_agreement'
  post 'isr/ia/:id',      to: 'isr_interfaces#create_ia'
  patch 'isr/ia/:id',     to: 'isr_interfaces#update_ia'
  put   'isr/ia/:id',     to: 'isr_interfaces#update_ia'
  delete 'isr/ia/:id',    to: 'isr_interfaces#destroy_ia'
  get 'isr/ia/:id/all',   to: 'isr_interfaces#show_ia_all',   as: 'isr_agreement_details'
  get 'isr/ia/:id/icf',   to: 'isr_interfaces#show_ia_icf',   as: 'isr_agreement_icf'
  get 'isr/ia/:id/edit',  to: 'isr_interfaces#edit_ia',       as: 'edit_isr_agreement'
  get 'isr/ia/:id/new',   to: 'isr_interfaces#new_wf',        as: 'new_isr_workflow'
  get 'isr/:id/new',      to: 'isr_interfaces#new_ia',        as: 'new_isr_agreement'
  get 'isr/:id/wdr',      to: 'isr_interfaces#edit_wdr',      as: 'withdraw_isr_interface'
  resources :isr_interfaces, path: 'isr'
  get 'scl/check', to: 'location_codes#update_check', as: 'location_codes_check'
  resources :location_codes, path: 'scl'
  resources :network_lines, path: 'nln'
  resources :network_stations, path: 'nst'
  resources :network_stops, path: 'nso'
  resources :pcp_categories, path: 'pcc'
  get 'pca/stats', to: 'pcp_all_subjects#stats', as: 'pcp_statistics'
  resources :pcp_all_subjects, path: 'pca'
  resources :pcp_subjects, path: 'pcs' do
    resources :pcp_items, path: 'pci', shallow: true
    resources :pcp_members, path: 'pcm', shallow: true
  end
  # additional routes for pcp_my_subjects
  get 'pcs/:id/release', to: 'pcp_subjects#update_release', as: 'pcp_subject_release'
  get 'pcs/:id/history', to: 'pcp_subjects#show_history', as: 'pcp_subject_history'
  get 'pcs/:id/reldoc/:step_no', to: 'pcp_subjects#show_release', as: 'pcp_release_doc'
  # additional routes for pcp_items
  get 'pci/:id/next', to: 'pcp_items#show_next', as: 'pcp_item_next'
  get 'pci/:id/publish', to: 'pcp_items#update_publish', as: 'pcp_item_publish'
  # shallow routing for PCP Comments, handling by pcp_items_controller
  post 'pci/:id/pco', to: 'pcp_items#create_comment', as: 'create_pcp_comment'
  get 'pci/:id/pco/new', to: 'pcp_items#new_comment', as: 'new_pcp_comment'
  get 'pco/:id/edit', to: 'pcp_items#edit_comment', as: 'edit_pcp_comment'
  put 'pco/:id', to: 'pcp_items#update_comment', as: 'pcp_comment'
  patch 'pco/:id', to: 'pcp_items#update_comment'
  delete 'pco/:id', to: 'pcp_items#destroy_comment'
  #
  resources :people, path: 'apt'
  resources :phase_codes, path: 'ppc'
  resources :product_codes, path: 'scp'
  resource  :profile, only: [ :show, :edit, :update ]
  resources :programme_activities, path: 'ppa'
  resources :references, path: 'ref'
  resources :region_names, path: 'rnc'
  resources :responsibilities, path: 'rpp'
  resources :rfc_documents, path: 'rcd'
    get 'rsr/info', to: 'rfc_status_records#info_workflow', as: 'rfc_workflow_info'
    get 'rsr/stats', to: 'rfc_status_records#stats', as: 'rfc_statistics'
  resources :rfc_status_records, path: 'rsr'
  resources :s_document_logs, path: 'sdl'
  resources :a_document_logs, path: 'adl'
  resources :service_codes, path: 'scv'
  resources :siemens_phases, path: 'spc'
  get 'sii/:id/all', to: 'sir_items#show_all', as: 'sir_item_details'
  get 'sil/:sir_log_id/sii/stats', to: 'sir_items#show_stats', as: 'sir_item_stats'
  resources :sir_logs, path: 'sil' do
    resources :sir_items, path: 'sii', shallow: true do
      resources :sir_entries, path: 'sie', shallow: true, only: [ :new, :create, :show, :edit, :update, :destroy ]
    end
  end
  resources :standards_bodies, path: 'sso'
  resources :statistics, path: 'sdh', only: :index
  resources :submission_groups, path: 'sgp'
  resources :web_links, path: 'wlk'
  resources :all_tia_lists, path: 'atl'
  resources :my_tia_lists, path: 'mtl' do
    resources :our_tia_items, path: 'oti', shallow: true
  end
    get 'mti/:id/info', to: 'my_tia_items#info', as: 'my_tia_item_info'
    get 'oti/:id/info', to: 'our_tia_items#info', as: 'our_tia_item_info'
  resources :my_tia_items, path: 'mti'
  resources :unit_names, path: 'unc'
  resources :my_change_requests, path: 'mcr'
    get 'mcr/new/:feature_id/(:detail)' => 'my_change_requests#new', as: :add_my_change_request 
  # rarely used ...
  resources :a1_codes, path: 'a1c'
  resources :a2_codes, path: 'a2c'
  resources :a3_codes, path: 'a3c'
  resources :a4_codes, path: 'a4c'
  resources :a5_codes, path: 'a5c'
  resources :a6_codes, path: 'a6c'
  resources :a7_codes, path: 'a7c'
  resources :a8_codes, path: 'a8c'
  end
end