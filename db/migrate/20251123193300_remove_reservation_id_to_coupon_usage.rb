class RemoveReservationIdToCouponUsage < ActiveRecord::Migration[7.2]
  def change
    remove_column :coupon_usages, :reservation_id
  end
end
