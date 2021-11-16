class NoticeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.notice_to_mail.subject
  #
  #  Preview all emails (changing notice id at the end): http://localhost:3000/rails/mailers/notice_mailer/notice_to_mail?id=1
  #
  def notice_to_mail(email, notice)
    @notice = notice
    mail to: email, subject: @notice.title
  end
end
