require 'rails_helper'

describe Util::UserDbManager do
  let(:username) { 'testuser' }
  let(:original_password) { 'original_password' }
  let(:dummy_password) { ENV['UNCONFIRMED_USER_PASSWORD'] }

  subject { described_class.new }

  context 'when backing up user info' do
    it 'should create 3 backup files and send an email' do
      allow_any_instance_of(Util::UserDbManager).to receive(:pg_dumpall_command).and_return('pg_dumpall')  # different version on server
      subject.run_command_line('ln -s /aact-files public/static') # now put it back
      fm=Util::FileManager.new
      expect(UserMailer).to receive(:send_backup_notification).exactly(1).times
      # first make sure the files don't already exist
      fm.remove_todays_user_backup_tables
      expect(File.exist?(fm.user_table_backup_file)).to eq(false)
      expect(File.exist?(fm.user_event_table_backup_file)).to eq(false)
      expect(File.exist?(fm.user_account_backup_file)).to eq(false)
      # run the backups
      subject.backup_user_info
      # make sure the files exist
      expect(File.exist?(fm.user_table_backup_file)).to eq(true)
      expect(File.exist?(fm.user_event_table_backup_file)).to eq(true)
      expect(File.exist?(fm.user_account_backup_file)).to eq(true)

      # make sure files have content
      table1_size=File.size?(fm.user_table_backup_file)
      table2_size=File.size?(fm.user_event_table_backup_file)
      table3_size=File.size?(fm.user_account_backup_file)

      expect(table1_size).to be > 800
      expect(table2_size).to be > 800
      expect(table3_size).to be > 800
    end

    it 'should create a user event that reports a problem' do
      UserEvent.destroy_all
      subject.run_command_line('rm public/static')  # problem: symbolic link it depends on doesn't exist
      subject.backup_user_info
      expect(UserEvent.count).to eq(1)
      expect(UserEvent.first.event_type).to eq('backup users problem')
      subject.run_command_line('ln -s /aact-files public/static') # now recreate the symbolic link
    end
  end

  context 'when managing user accounts' do
    it 'should create initial db account that user cannot access' do
      user=User.create({:last_name=>'lastname',:first_name=>'firstname',:email=>'email@mail.com',:username=>username,:password=>original_password,:skip_password_validation=>true})
      # make sure user account doesn't already exist
      system 'grant_db_privs.sh'
      subject.remove_user(user.username)
      expect(subject.can_create_user_account?(user)).to be(true)
      expect(subject.create_user_account(user)).to be(true)

      expect(subject.user_account_exists?(user.username)).to be(true)
      expect(subject.can_create_user_account?(user)).to be(false)
      user_rec=described_class.new.pub_con.execute("SELECT * FROM pg_catalog.pg_group where groname = '#{user.username}'")
      expect(user_rec.count).to eq(1)
      allow_any_instance_of(User).to receive(:can_access_db?).and_return( true )
      # ensure app user logged into db connections
      Public::PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
        username: ENV['AACT_DB_SUPER_USERNAME'])
      @dbconfig = YAML.load(File.read('config/database.yml'))
      ActiveRecord::Base.establish_connection @dbconfig[:test]
      user.remove
      expect(User.count).to eq(0)
      user_rec=described_class.new.pub_con.execute("SELECT * FROM pg_catalog.pg_group where groname = '#{user.username}'")
      expect(user_rec.count).to eq(0)
    end

  end
end
