class NoticeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.notice_to_mail.subject
  # 
  #  Preview all emails at http://localhost:3000/rails/mailers/notice_mailer
  def notice_to_mail(notice)
    @notice = notice

    mail to: @notice.user.email,
    subject: @notice.title
  end
end
