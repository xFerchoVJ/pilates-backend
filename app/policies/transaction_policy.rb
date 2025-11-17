class TransactionPolicy < ApplicationPolicy
  def index?
    user&.admin? || user&.user?
  end

  def show?
    user&.admin? || user&.id == record.user_id
  end
end
