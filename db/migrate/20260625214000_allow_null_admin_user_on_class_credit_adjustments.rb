class AllowNullAdminUserOnClassCreditAdjustments < ActiveRecord::Migration[7.2]
  def change
    change_column_null :class_credit_adjustments, :admin_user_id, true
  end
end
