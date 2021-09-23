require 'rails_helper'

describe User do
  # before(:all) do
  #   # In case tests failed in previous pass, remove db account in public database
  #   begin
  #     Util::UserDbManager.remove_user(User.new(:username=>'spec_test'))
  #   rescue
  #   end
  # end

before do
  Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
      database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
      username: AACT::Application::AACT_DB_SUPER_USERNAME,
    ).connection
end

  it { should validate_length_of(:first_name).is_at_most(100) }
  it { should validate_length_of(:last_name).is_at_most(100) }
  it { should validate_length_of(:username).is_at_most(64) }

  it "isn't added if username is postgres" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.destroy_all
    expect(User.count).to eq(0)
    username='postgres'
    user=User.new(:first_name=>'Illegal', :last_name=>'User',:email=>'illegal_user@duke.edu',:username=>username,:password=>'aact',:password_confirmation=>'aact')
    expect( user.valid? ).to eq(false)
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username Database account already exists for 'postgres'")
    expect( User.count ).to eq(0)
  end

  it "isn't accepted unless first char of username is alpha" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.destroy_all
    expect(User.count).to eq(0)
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'1rspec_test',:password=>'aact',:password_confirmation=>'aact')
    expect( user.valid? ).to eq(false)
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username can contain only lowercase characters and numbers, Username must start with a lowercase character")
    expect(User.count).to eq(0)
  end

  it "isn't accepted if username has a hyphen" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.destroy_all
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'r1-ectest',:password=>'aact',:password_confirmation=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username can contain only lowercase characters and numbers")
    expect(User.count).to eq(0)
  end

  it "isn't accepted if username is mixed case" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.destroy_all
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'EcTest',:password=>'aact',:password_confirmation=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username can contain only lowercase characters and numbers, Username must start with a lowercase character")
    expect(User.count).to eq(0)
  end

  it "accepted with a valid username and logs appropriate events when adding/removing user" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    UserEvent.destroy_all
    User.destroy_all
    Util::UserDbManager.new.remove_user('r1ectest')
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'first.last@duke.edu',:username=>'r1ectest',:password=>'aact',:password_confirmation=>'aact')
    user.skip_password_validation=true
    user.save!
    expect(User.count).to eq(1)
    expect(User.first.username).to eq('r1ectest')

    user.remove
    expect(User.count).to eq(0)
    expect(UserEvent.last.event_type).to eq('remove')
  end
  describe "when a user signs up" do
    before do
      @dbconfig = YAML.load(File.read('config/database.yml'))
      ActiveRecord::Base.establish_connection @dbconfig[:test]
      
      @con=Public::PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
        database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
        username: AACT::Application::AACT_DB_SUPER_USERNAME,
      ).connection
      @username='rspec'
      @pwd='aact_pwd'
      Util::UserDbManager.new.remove_user(@username)
      # remove all existing users - both from Users table and db accounts
      allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
      User.all.each{|user| user.remove } 
      @user=User.new(first_name: 'first', last_name: 'last', email: 'rspec.test@duke.edu', username: @username, password: @pwd)
      @user.skip_password_validation=true
      @user.save!
    end
    after do
      @con=Public::PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
        database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
        username: AACT::Application::AACT_DB_SUPER_USERNAME,
      ).connection
    end

    it "an unconfirmed user db account is created in public db" do
      expect(User.count).to eq(1)
      expect(@user.sign_in_count).to eq(0)
      # user added to db as un-confirmed
      expect(Util::UserDbManager.new.user_account_exists?(@user.username)).to be(true)
    end
    it "the user can't use the database if they are not confirmed" do
      # user cannot login until they confirm their email address
      begin
        con=Public::PublicBase.establish_connection(
          adapter: 'postgresql',
          encoding: 'utf8',
          hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
          database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
          username: @user.username,
          password: @pwd,
        ).connection
      rescue => e
        e.inspect
        expect(e.message).to eq("FATAL:  password authentication failed for user \"rspec\"\n") 
      end
    end
    it "the user can use the database if they are confirmed" do
      @user.confirm  #simulate user email response confirming their account
      
      # once confirmed via email, user should be able to login to their account
      con=Public::PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
        database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
        username: @user.username,
        password: @pwd,
      ).connection
      expect(con.active?).to eq(true)
      con.execute('show search_path;')
      expect(con.execute('select count(*) from ctgov.studies').count).to eq(1)
      expect(con.execute('select count(*) from ctgov_beta.studies').count).to eq(1)
      con.disconnect!
      expect(con.active?).to eq(false)
      con=nil
    end
    it 'if the user is removed they can no longer access the database' do
      @user.confirm
      @user.remove
      expect(User.count).to eq(0)
      # user can no longer access the public database
      expect { Public::PublicBase.establish_connection(
        adapter:'postgresql',
        encoding:'utf8',
        hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
        database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
        username: @user.username,
        password: @pwd
      ).connection}.to raise_error(PG::ConnectionBad) # for postgres 13
    end
    it "isn't accepted if special char in username" do
      User.all.each{|user| user.remove } 
      user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec!_test',:password=>'aact')
      expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username can contain only lowercase characters and numbers')
      expect(User.count).to eq(0)
      begin
        con = Public::PublicBase.establish_connection(
          adapter: 'postgresql',
          encoding: 'utf8',
          hostname: AACT::Application::AACT_PUBLIC_HOSTNAME,
          database: AACT::Application::AACT_PUBLIC_DATABASE_NAME,
          username: user.username,
          password: user.password
        ).connection
      rescue => e
        expect(e.class).to eq(PG::ConnectionBad) # for postgres 13
        expect(e.message).to eq("FATAL:  password authentication failed for user \"rspec!_test\"\n")
        # postgres 9.6
        # expect(e.class).to eq(ActiveRecord::NoDatabaseError) 
        # expect(e.message).to eq("FATAL:  role \"rspec!_test\" does not exist\n")
      end
    end
  end

  

end
