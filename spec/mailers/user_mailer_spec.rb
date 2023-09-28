require 'rails_helper'
require 'spec_helper'

describe UserMailer, type: :mailer do
  describe 'user event notification' do
    let!(:user) { User.new(:email=>'test@gmail.com', :first_name=>'Fname', :last_name=>'Lname', :username=>'username') }
  end
end
