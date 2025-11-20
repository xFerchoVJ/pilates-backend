class ClassCreditsPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.user?
  end

  def show?
    user&.admin? || user&.user?
  end
end
