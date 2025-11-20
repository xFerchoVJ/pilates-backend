class ClassWaitlistNotificationPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.user?
  end

  def create?
    user&.user?
  end

  def destroy?
    user&.id == record.user_id
  end

  def show?
    user&.admin? || user&.user?
  end
end
