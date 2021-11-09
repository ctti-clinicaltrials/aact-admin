# Preview all emails at http://localhost:3000/rails/mailers/notice_mailer
class NoticeMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notice_mailer/notice_to_mail
  def notice_to_mail

    if !params[:user].nil?
      notice = Notice.unsent.where(user_id: params[:user])[0]

    else
      notice=Notice.unsent.first
    end
    NoticeMailer.notice_to_mail(notice)

  end

end
