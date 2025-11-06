class ReservationPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.instructor?
  end

  def show?
    user&.admin? || user&.instructor? || record.user_id == user&.id
  end

  def create?
    user&.admin? || record.user_id == user&.id
  end

  def update?
    user&.admin? || record.user_id == user&.id
  end

  def destroy?
    user&.admin? || record.user_id == user&.id
  end

  def create_with_payment?
    user.present?
  end

  def confirm_payment?
    user.present?
  end
end
