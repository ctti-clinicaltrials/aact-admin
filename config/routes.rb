Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    passwords:     'users/passwords'}

  root "pages#home"

  get "/airbrake" => "pages#airbrake"

  get "/data_dictionary"      => "dictionary#show"
  get "/activities"           => "database_activity#show"
  get 'dictionary/show'

  get "/connect"              => "pages#connect"
  get "/download"             => "pages#download"
  get "/learn_more"           => "pages#learn_more"
  get "/covid_19"             => "pages#covid_19"
  get "/covid_19_fields"      => "pages#covid_19_fields"
  get "/pipe_files"           => "pages#pipe_files"
  get "/pipe_files_with_r"    => "pages#pipe_files_with_r"
  get "/pipe_files_with_sas"  => "pages#pipe_files_with_sas"
  get "/pgadmin"              => "pages#pgadmin"
  get "/points_to_consider"   => "pages#points_to_consider"
  get "/psql"                 => "pages#psql"
  get "/r"                    => "pages#r"
  get "/sanity_check_report"  => "pages#sanity_check", as: :sanity_check
  get "/sas"                  => "pages#sas"
  get "/schema"               => "pages#schema"
  get "/snapshots"            => "pages#snapshots"
  get "/snapshot_archive"     => "pages#snapshot_archive"
  get "/technical_documentation"    => "pages#technical_documentation"
  get "/update_policy"        => "pages#update_policy"
  get "/deploy_code"          => "pages#deploy_code"

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
  
  resources :definitions
  resources :users
  resources :shared_data, param: :schema_name
  resources :release_notes
  resources :datasets
  resources :attachments
  resources :use_cases
  resources :use_case_attachments
end
