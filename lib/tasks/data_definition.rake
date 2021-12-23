namespace :populate do
    desc 'Populate data definition'
    task :data_definition, [:force] => :environment do
        DataDefinition.populate
    end
end