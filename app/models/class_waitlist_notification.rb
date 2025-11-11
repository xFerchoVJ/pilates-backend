class ClassWaitlistNotification < ApplicationRecord
  belongs_to :class_session
  belongs_to :user

  validates :user_id, uniqueness: { scope: :class_session_id }
end
