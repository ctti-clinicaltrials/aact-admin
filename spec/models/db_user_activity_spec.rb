require 'rails_helper'

# Dependencies (crontab):
#     Public AACT DB Server shell script (summarize_db_usage.sh) extracts data from logs:
#         dt=`date +%Y%m%d`
#         file_name=/aact-files/other/$dt_user_activity-count.txt
#         sudo grep EDT /aact-files/logs/postgresql-*.log | cut -d " " -f 5 | sort | uniq -c > $file_name
#     Private AACT Server shell script (summarize_db_usage.sh) retrieves the file:
#         dt=`date +%Y%m%d`
#         file_name=/aact-files/other/$dt_user-activity-count.txt
#         scp ctti@174.138.61.222:/aact-files/other/$file /aact-files/other

describe DbUserActivity do
  it "imports stats from a predictably formatted file" do
    described_class.destroy_all
    data_from_logs = "spec/support/flat_data/20180808_user-activity-count.txt"
    described_class.populate_from_file(data_from_logs,'weekly')

    expect(described_class.count).to eq(88)
    example = described_class.where('username=?','tarjan').first
    expect(example.unit_of_time).to eq('weekly')
    expect(example.event_count).to eq(42213)
    expect(example.display_when_recorded).to eq(DateTime.parse("2018-08-08").strftime('%Y/%m/%d'))
  end

  it "adds activity info to the user records" do
    username='tarjan'
    Util::UserDbManager.new.remove_user(username)
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'first.last@duke.edu',:username=>username,:password=>'aact',:password_confirmation=>'aact')
    user.skip_password_validation=true
    user.save!
    described_class.update_user_records
    user = User.where('username=?', username).first
    expect(user.db_activity).to eq(42213)
    expect(user.display_last_db_activity).to eq('2018/08/08')
    user.remove
    User.destroy_all
    Util::UserDbManager.new.remove_user(username)
    DbUserActivity.destroy_all
  end

end
