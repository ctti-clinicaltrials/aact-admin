namespace :populate do
    desc 'Populate data definitions'
    task :data_definition, [:force] => :environment do
        DataDefinition.populate
    end
end