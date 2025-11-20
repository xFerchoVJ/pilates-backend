class Api::V1::ClassWaitlistNotificationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :class_session_id, :notified_at
  belongs_to :user, serializer: Api::V1::UsersSerializer
  belongs_to :class_session, serializer: Api::V1::ClassSessionSerializer
end
