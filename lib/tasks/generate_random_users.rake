namespace :db do
  desc "Generate 50 random users with db_activity and last_db_activity"
  task generate_random_users: :environment do
    50.times do |i|
      User.create!(
        email: "test#{i + 1}@test.com",
        first_name: "Test#{i + 1}",
        last_name: "User#{i + 1}",
        username: "testuser#{i + 1}",
        password: "testing123",
        db_activity: rand(0..1000),
        last_db_activity: rand(1..30).days.ago + rand(0..23).hours + rand(0..59).minutes,
        admin: false
      )
    end

    puts "Successfully created 50 random users"
  end
end
