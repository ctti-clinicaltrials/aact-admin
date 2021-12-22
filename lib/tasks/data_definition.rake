namespace :data do
    task :run, [:force] => :environment do
        DataDefinition.populate
    end
end