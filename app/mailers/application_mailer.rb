class ApplicationMailer < ActionMailer::Base
  default from: "AACT <ctti-aact@duke.edu>"
  layout 'mailer'

  def self.admin_addresses
    if Rails.env.capitalize == 'Production'
      ['sheri.tibbs@duke.edu', 'ctti-aact@duke.edu']
    else
     ['sheri.tibbs@duke.edu', 'sheri.tibbs@gmail.com']
    end
  end

end
