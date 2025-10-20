class AddClassSpaceToReservations < ActiveRecord::Migration[7.2]
  def change
    add_reference :reservations, :class_space, null: false, foreign_key: true
  end
end
