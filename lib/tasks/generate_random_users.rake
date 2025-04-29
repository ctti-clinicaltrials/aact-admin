namespace :db do
  desc "Generate 50 random users with db_activity, last_db_activity, created_at"
  task generate_random_users: :environment do
    50.times do |i|
      User.create!(
        email: "test#{i + 1}@test.com",
        first_name: "Test#{i + 1}",
        last_name: "User#{i + 1}",
        username: "testuser#{i + 1}",
        password: "test123",
        db_activity: rand(0..1000),
        last_db_activity: rand(1..60).days.ago.to_date,
        admin: false
      )
    end

    puts "Successfully created 50 random users"
  end
end