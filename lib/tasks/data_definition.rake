desc 'Populate the data'
namespace :populate do
    task :datadefinition, [:force] => :environment do
        DataDefinition.populate
    end
end