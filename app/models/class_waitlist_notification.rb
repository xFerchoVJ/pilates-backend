class ClassWaitlistNotification < ApplicationRecord
  belongs_to :class_session
  belongs_to :user

  validates :user_id, uniqueness: { scope: :class_session_id }

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_class_session, ->(class_session_id) { where(class_session_id: class_session_id) }
  scope :notified_from, ->(date) { where("notified_at >= ?", date.beginning_of_day) }
  scope :notified_to, ->(date) { where("notified_at <= ?", date.end_of_day) }
end
