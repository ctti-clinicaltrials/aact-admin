Rails.application.routes.draw do

  namespace :admin do
    resources :notices
      get "/notices/:id/send_notice" => "notices#send_notice"
  end

  # Adding these routes connects those requests to the appropriate actions of the errors controller.
  # Using match ... :via => :all allows the error pages to be displayed for any type of request (GET, POST, PUT, etc.)
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  devise_for :users, controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    passwords:     'users/passwords'}

  devise_scope :user do
    get 'users/password', :to => 'users/registrations#password'
  end

  root "pages#home"

  get 'file_records/active_url'
  get 'summary/aact'

  get "/airbrake"             => "pages#airbrake"

  get "/data_dictionary"      => "dictionary#show"
  get "/activities"           => "database_activity#show"
  get 'dictionary/show'
  # get "admin/notices/:id/send_notice" => "admin/notices#send_notice"
  get "/connect"              => "pages#connect"
  get "/download"             => "pages#download"
  get 'faq'                   => "pages#faq"
  get "/learn_more"           => "pages#learn_more"
  get "/covid_19"             => "pages#covid_19"
  get "/covid_19_fields"      => "pages#covid_19_fields"
  get "/pipe_files"           => "pages#pipe_files"
  get "/pipe_files_with_r"    => "pages#pipe_files_with_r"
  get "/pipe_files_with_sas"  => "pages#pipe_files_with_sas"
  get "/pgadmin"              => "pages#pgadmin"
  get "/points_to_consider"   => "pages#points_to_consider"
  get "/postgres"             => "pages#postgres"
  get "/r"                    => "pages#r"
  get "/sanity_check_report"  => "pages#sanity_check", as: :sanity_check
  get "/sas"                  => "pages#sas"
  get "/saved_query_doc"      => "pages#saved_query_doc"
  get "/schema"               => "pages#schema"
  get "/snapshots"            => "pages#snapshots"
  get "/snapshot_archive"     => "pages#snapshot_archive"
  get "/technical_documentation"    => "pages#technical_documentation"
  get "/update_policy"        => "pages#update_policy"
  get "/deploy_code"          => "pages#deploy_code"
  get "/contactus"            => "pages#contactus"

  get "/query"                => "query#index", as: :query

  get "/install_postgres"     => "postgres_documentation#install_postgres"
  get "/credentials"          => "credentials#show"

  get "/admin_run_loads"      => "faq#admin_run_loads"
  get "/admin_remove_user"    => "faq#admin_remove_user"
  get "/admin_add_project"    => "faq#admin_add_project"
  get "/faq_proj_gather_info" => "faq#proj_gather_info"
  get "/faq_proj_change_app"  => "faq#proj_change_app"

  get "/support_grant_permission"  => "faq#support_grant_permission"
  get "/support_registration_failed"  => "faq#support_registration_failed"
  get "/support_user_cannot_access_db"  => "faq#support_user_cannot_access_db"

  get "/tech_access_servers"  => "faq#tech_access_servers"
  get "/tech_apply_ctgov_changes"  => "faq#tech_apply_ctgov_changes"
  get "/tech_deploy_code"     => "faq#tech_deploy_code"

  #beta
  get "/beta/migration" => "beta#migration"
  get "/beta/schema"     => "beta#schema"
  get "/beta/data_dictionary" => "beta#data_dictionary"

  #archive
  get "/archive"           => "archive#archive"
  get "/archive/data_dictionary" => "archive#data_dictionary"
  get "/archive/schema"    => "archive#schema"
  get "/archive/download"  => "archive#download"
  get "/archive/snapshots" => "archive#snapshots"
  get "/archive/pipe_files" => "archive#pipe_files"
  get "/archive/covid_19"   => "archive#covid_19"
  get "/archive/pipe_files_with_r"    => "archive#pipe_files_with_r"
  get "/archive/pipe_files_with_sas"  => "archive#pipe_files_with_sas"
  get 'my/queries', to: 'saved_queries#my_queries'
  get '/queries', to: 'saved_queries#index'

  #digitalocean
  get "/static/:type/:time/:filename(:format)" => "file_records#active_url"

  resources :file_records, only: [:index, :show]
  resources :definitions
  resources :data_definitions
  resources :users
  resources :shared_data, param: :schema_name
  resources :release_notes
  resources :releases
  resources :datasets
  resources :attachments
  resources :use_cases
  resources :use_case_attachments
  resources :events
  resources :verifiers
  resources :saved_queries
  resources :study_statistics_comparisons
  resources :background_jobs
  resources :study_searches
  
end
