class ClassSessionPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.instructor? || user&.user?
  end

  def show?
    user&.admin? || user&.instructor? || user&.user?
  end

  def create?
    user&.admin? || user&.instructor?
  end

  def update?
    user&.admin? || user&.instructor?
  end

  def destroy?
    user&.admin? || user&.instructor?
  end

  def create_recurring?
    user&.admin?
  end
end
