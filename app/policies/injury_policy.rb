class InjuryPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin? || user&.id == record.user_id  || user&.instructor?
  end

  def create?
    user&.admin? || user&.id == record.user_id
  end

  def update?
    user&.admin? || user&.id == record.user_id
  end

  def destroy?
    user&.admin? || user&.id == record.user_id
  end
end
