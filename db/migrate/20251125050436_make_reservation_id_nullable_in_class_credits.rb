class MakeReservationIdNullableInClassCredits < ActiveRecord::Migration[7.2]
  def change
    change_column_null :class_credits, :reservation_id, true
  end
end
