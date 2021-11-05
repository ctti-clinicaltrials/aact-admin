class NoticeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.notice_to_mail.subject
  #
  def notice_to_mail(notice)
    @notice = notice
    

    mail to: "asya.bykova@gmail.com",
        subject: "New notice from AACT"
  end
end
