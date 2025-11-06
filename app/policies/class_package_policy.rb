class ClassPackagePolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.user?
  end

  def show?
    user&.admin? || user&.user?
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end

  def purchase_with_payment?
    user&.user?
  end
end
