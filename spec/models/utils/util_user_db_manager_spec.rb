require 'rails_helper'

describe Util::UserDbManager do
  let(:username) { 'testuser' }
  let(:original_password) { 'original_password' }
  let(:dummy_password) { ENV['UNCONFIRMED_USER_PASSWORD'] }

  subject { described_class.new }

  context 'when managing user accounts' do
    it 'should create initial db account that user cannot access' do
      user=User.create({:last_name=>'lastname',:first_name=>'firstname',:email=>'email@mail.com',:username=>username,:password=>original_password,:skip_password_validation=>true})
      # make sure user account doesn't already exist
      Util::DbManager.new.grant_db_privs
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
        username: ENV['DB_SUPER_USERNAME'])
      @dbconfig = YAML.load(File.read('config/database.yml'))
      ActiveRecord::Base.establish_connection @dbconfig[:test]
      user.remove
      expect(User.count).to eq(0)
      user_rec=described_class.new.pub_con.execute("SELECT * FROM pg_catalog.pg_group where groname = '#{user.username}'")
      expect(user_rec.count).to eq(0)
    end

  end
end
