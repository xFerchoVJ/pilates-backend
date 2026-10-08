class ClassSessionTemplatePolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def duplicate?
    user&.admin?
  end

  def archive?
    user&.admin?
  end

  def preview?
    user&.admin?
  end

  def publish?
    user&.admin?
  end
end
