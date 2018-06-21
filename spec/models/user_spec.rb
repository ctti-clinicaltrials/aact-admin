require 'rails_helper'

describe User do
  before(:all) do
    # In case tests failed in previous pass, remove db account in public database
    begin
      Util::UserDbManager.remove_user(User.new(:username=>'spec_test'))
    rescue
    end
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
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username cannot contain special chars, Username must start with an alpha character")
    expect(User.count).to eq(0)
  end

  it "isn't accepted if username has a hyphen" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'1test@duke.edu',:username=>'r1-ectest',:password=>'aact',:password_confirmation=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Username cannot contain special chars")
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

  it "creates unconfirmed user db account in public db" do
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['DB_SUPER_USERNAME'],
    ).connection
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.all.each{|user| user.remove }  # remove all existing users - both from Users table and db accounts

    username='rspec'
    pwd='aact_pwd'
    Util::UserDbManager.new.remove_user(username)

    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>username,:password=>pwd)
    user.skip_password_validation=true
    user.save!

    expect(User.count).to eq(1)
    expect(user.sign_in_count).to eq(0)
    # user added to db as un-confirmed
    expect(Util::UserDbManager.new.user_account_exists?(user.username)).to be(true)
    # user cannot login until they confirm their email address
    begin
      con=Public::PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
        username: user.username,
        password: pwd,
      ).connection
    rescue => e
      e.inspect
      expect(e.message).to eq("FATAL:  role \"rspec\" is not permitted to log in\n")
      expect(con).to be(nil)
    end
    #  Go back to superuser-owned connections...
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['DB_SUPER_USERNAME'],
    ).connection
    # once db connections are back to normal, confirm the user
    user.confirm  #simulate user email response confirming their account

    # once confirmed via email, user should be able to login to their account
    con=Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: user.username,
      password: pwd,
    ).connection
    expect(con.active?).to eq(true)
    con.execute('show search_path;')
    expect(con.execute('select count(*) from ctgov.studies').count).to eq(1)
    con.disconnect!
    expect(con.active?).to eq(false)
    con=nil

    # Again... reset db connections to normal...
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['DB_SUPER_USERNAME'],
    ).connection

    # Then remove the user
    user.remove
    expect(User.count).to eq(0)
    # user can no longer access the public database
    expect { Public::PublicBase.establish_connection(
      adapter:'postgresql',
      encoding:'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: user.username,
    ).connection}.to raise_error(PG::ConnectionBad)
    # Subsequent spec tests use this public db connection. Force reset back to test db.
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['DB_SUPER_USERNAME'],
    ).connection

  end

  it "isn't accepted if special char in username" do
    allow_any_instance_of(described_class).to receive(:can_access_db?).and_return( true )
    User.all.each{|user| user.remove}  # remove all existing users - both from Users table and db accounts
    user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec!_test',:password=>'aact')
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username cannot contain special chars')
    expect(User.count).to eq(0)
    begin
      Public::PublicBase.establish_connection(
        adapter: 'postgresql',
        encoding: 'utf8',
        hostname: ENV['AACT_PUBLIC_HOSTNAME'],
        database: ENV['AACT_PUBLIC_DATABASE_NAME'],
        username: user.username,
        password: user.password
      ).connection
    rescue => e
      expect(e.class).to eq(PG::ConnectionBad)
      expect(e.message).to eq("FATAL:  password authentication failed for user \"rspec!_test\"\n")
    end
    # Should factor this out to happen before each test
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=Public::PublicBase.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['AACT_PUBLIC_HOSTNAME'],
      database: ENV['AACT_PUBLIC_DATABASE_NAME'],
      username: ENV['DB_SUPER_USERNAME'],
    ).connection

  end

end
