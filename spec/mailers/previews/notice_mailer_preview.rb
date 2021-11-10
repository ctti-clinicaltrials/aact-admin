# Preview all emails at http://localhost:3000/rails/mailers/notice_mailer
class NoticeMailerPreview < ActionMailer::Preview

  #  Preview all emails (changing notice id at the end): http://localhost:3000/rails/mailers/notice_mailer/notice_to_mail?id=1
  def notice_to_mail

    notice=Notice.find(params[:id])
    NoticeMailer.notice_to_mail(notice)

  end

end
