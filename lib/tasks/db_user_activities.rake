namespace :db do
  desc "Generate one weekly db_user_activity record per user for past Sundays in the current month"
  task generate_weekly_activity_for_current_month: :environment do
    now = Time.zone.now
    start_of_month = now.beginning_of_month
    end_of_today = now.end_of_day

    past_sundays = (start_of_month.to_date..now.to_date).select { |date| date.sunday? }.map do |date|
      Time.zone.parse("#{date} 00:00:00")
    end

    if past_sundays.empty?
      puts "No past Sundays in the current month yet. Nothing was created."
      next
    end

    User.find_each do |user|
      when_recorded = past_sundays.sample
      created_time = when_recorded.change(hour: rand(6..10), min: rand(0..59), sec: rand(0..59))

      DbUserActivity.create!(
        username: user.username,
        event_count: rand(1..1000),
        when_recorded: when_recorded,
        unit_of_time: "weekly",
        created_at: created_time,
        updated_at: created_time
      )
    end

    puts "Generated db_user_activity records for #{User.count} users using Sundays from #{past_sundays.first.to_date} to #{past_sundays.last.to_date}."
  end
end
