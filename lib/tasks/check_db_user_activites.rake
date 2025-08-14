namespace :db_user_activities do
  desc "Check if there are db_user_activities for this Sunday and send Slack alert if not"
  task check_sunday: :environment do
    sunday = Date.today
    time = sunday.to_datetime.change({ hour: 4 })
    
    count = DbUserActivity.where(when_recorded: time).count
    

    if count.zero?
      require 'net/http'
      require 'uri'
      require 'json'

      uri = URI.parse(ENV["SLACK_WEBHOOK_URL"])
      header = {'Content-Type': 'application/json'}
      message = { text: "No entries were added to db_user_activities on Sunday (#{sunday})." }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = message.to_json
      response = http.request(request)

      puts "Slack notification sent. Response: #{response.code}"
    else
      puts "#{count} entries found. No Slack alert sent."
    end
  end
end
