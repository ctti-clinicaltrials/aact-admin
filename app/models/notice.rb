class Notice < ApplicationRecord
  belongs_to: user

  validates :title, :user_id, :emails_sent_at, presence: true
  validates :body, presence: true, length: { minimum: 10 }
  validates :send_emails, inclusion: [true, false]
  validates :visible, inclusion: [true, false]

  scope :unsent, -> { where(send_emails: false) }
  scope :sent, -> { where(send_emails: true)}

  scope :invisible, -> { where(visible: false) }
  scope :visible, -> { where(visible: true)}

end
