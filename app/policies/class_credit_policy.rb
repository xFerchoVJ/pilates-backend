class ClassCreditPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.user?
  end

  def show?
    user&.admin? || user&.id == record.user_id
  end

  def create?
    user&.admin?
  end
end
