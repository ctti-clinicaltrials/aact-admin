require 'rails_helper'

describe User do
  it { should validate_length_of(:first_name).is_at_most(17) }
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

  describe "when a user signs up" do
    before do
      @user = build(:user, password: 'password')
      @user.skip_password_validation = true
      @user.save!
    end

    after do
      @user&.destroy
    end

    it "an unconfirmed user db account is created in public db" do
      expect(User.count).to eq(1)
      expect(@user.sign_in_count).to eq(0)
      # user added to db as un-confirmed
      expect(Util::UserDbManager.new.user_account_exists?(@user.username)).to be(true)
    end

    it "the user can't use the database if they are not confirmed" do
      # user cannot login until they confirm their email address
      cmd = "PGPASSWORD=password psql -U #{@user.username} -h #{AACT::Application::PUBLIC_DB_HOST} -d aact_public_test"
      stdout, stderr, status = Open3.capture3(cmd)
      expect(stderr).to match(/password authentication failed for user \"#{@user.username}\"/)
    end

    xit "the user can use the database if they are confirmed" do
      @user.confirm  #simulate user email response confirming their account
      
      # once confirmed via email, user should be able to login to their account
      cmd = "PGPASSWORD=password psql -U #{@user.username} -h #{AACT::Application::PUBLIC_DB_HOST} -d aact_public_test -c 'select 1 + 1'"
      stdout, stderr, status = Open3.capture3(cmd)
      expect(stdout).to match(/1 row/)
    end

    it 'if the user is removed they can no longer access the database' do
      @user.confirm
      @user.destroy
      expect(User.count).to eq(0)
      cmd = "PGPASSWORD=password psql -U #{@user.username} -h #{AACT::Application::PUBLIC_DB_HOST} -d aact_public_test"
      stdout, stderr, status = Open3.capture3(cmd)
      expect(stderr).to match(/password authentication failed for user \"#{@user.username}\"/)
    end

    it "isn't accepted if special char in username" do
      User.all.each{|user| user.destroy } 
      user=User.new(:first_name=>'first', :last_name=>'last',:email=>'rspec.test@duke.edu',:username=>'rspec!_test',:password=>'aact')
      expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Username can contain only lowercase characters and numbers')
      expect(User.count).to eq(0)
    end
  end
end
