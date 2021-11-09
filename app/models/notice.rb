class Notice < ActiveRecord::Base
  belongs_to :user

  validates :title, :user_id,  :send_emails, :visible, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  # we want to send notice but haven't done it yet
  scope :unsent, -> { where(send_emails: true, emails_sent_at: nil)}
  # we want to send notice and already did it
  scope :sent, -> { where(send_emails: true).where.not(emails_sent_at: nil)}

  scope :invisible, -> { where(visible: false) }
  scope :visible, -> { where(visible: true)}

  after_save :send_notice

  def send_notice
    User.all.each do |user|
      user_notices= Notice.unsent.where(user_id: user.id)
      user_notices.each {|notice| NoticeMailer.notice_to_mail(notice).deliver_now}
    end
  end

end
