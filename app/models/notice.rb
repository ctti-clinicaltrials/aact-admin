class Notice < ActiveRecord::Base
  belongs_to :user

  validates :title, :user_id, :send_emails, :visible, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  # we want to send notice but haven't done it yet
  scope :unsent, -> { where(emails_sent_at: nil, send_emails: true) }
  # we want to send notice and already did it
  scope :sent, -> { where(send_emails: true).where.not(emails_sent_at: nil)}

  scope :invisible, -> { where(visible: false) }
  scope :visible, -> { where(visible: true)}

  after_create :send_notice

  def send_notice
    users = User.all.order(email: :asc)
    remaining = users.count
    users.each do |user|
      puts "#{remaining} #{user.email}"
      NoticeMailer.notice_to_mail(user.email, self).deliver_now
    end
    self.emails_sent_at = Time.now
    self.save
  end

end
