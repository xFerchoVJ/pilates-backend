class UserPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin? || user&.instructor? || user&.id == record.id
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin? || user&.id == record.id
  end

  def destroy?
    user&.admin? || user&.id == record.id
  end
end
