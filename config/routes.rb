Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: 'users/registrations',
                                    confirmations: 'users/confirmations',
                                    passwords:     'users/passwords'}

  root "pages#home"

  get "/data_dictionary"      => "dictionary#show"
  get "/activities"           => "database_activity#show"
  get 'dictionary/show'

  get "/connect"              => "pages#connect"
  get "/download"             => "pages#download"
  get "/learn_more"           => "pages#learn_more"
  get "/pipe_files"           => "pages#pipe_files"
  get "/pipe_files_with_r"    => "pages#pipe_files_with_r"
  get "/pipe_files_with_sas"  => "pages#pipe_files_with_sas"
  get "/pgadmin"              => "pages#pgadmin"
  get "/points_to_consider"   => "pages#points_to_consider"
  get "/psql"                 => "pages#psql"
  get "/r"                    => "pages#r"
  get "/release_notes"        => "pages#release_notes"
  get "/sanity_check_report"  => "pages#sanity_check", as: :sanity_check
  get "/sas"                  => "pages#sas"
  get "/schema"               => "pages#schema"
  get "/snapshots"            => "pages#snapshots"
  get "/snapshot_archive"     => "pages#snapshot_archive"
  get "/technical_documentation"    => "pages#technical_documentation"
  get "/update_policy"        => "pages#update_policy"

  get "/install_postgres"     => "postgres_documentation#install_postgres"
  get "/credentials"          => "credentials#show"
  get "/faq"                  => "faq#home"
  get "/admin_run_loads"      => "faq#admin_run_loads"
  get "/admin_remove_user"    => "faq#admin_remove_user"
  get "/tech_access_servers"  => "faq#access_servers"


  resources :definitions
  resources :users
  resources :use_cases
  resources :use_case_attachments
end
