class DevicePolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.instructor? || user&.user?
  end

  def show?
    user&.id == record.user_id
  end

  def create?
    user&.admin? || user&.instructor? || user&.user?
  end

  def update?
    user&.id == record.user_id
  end

  def destroy?
    user&.id == record.user_id
  end
end
