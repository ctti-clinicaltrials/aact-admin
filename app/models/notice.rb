class Notice < ApplicationRecord
  belongs_to: user

  validates :title, :user_id, :send_emails, :visible, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  scope :unsent, -> { where(emails_sent_at: nil, send_emails: true) }
  scope :sent, -> { where(send_emails: true).where.not(emails_sent_at: nil}

  scope :invisible, -> { where(visible: false) }
  scope :visible, -> { where(visible: true)}

end