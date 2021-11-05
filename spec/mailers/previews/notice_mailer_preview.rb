# Preview all emails at http://localhost:3000/rails/mailers/notice_mailer
class NoticeMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notice_mailer/notice_to_mail
  def notice_to_mail
    notice = Notice.last
    NoticeMailer.notice_to_mail(notice)
  end

end
