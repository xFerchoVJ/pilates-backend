class AddStatusToReservation < ActiveRecord::Migration[7.2]
  def change
    add_column :reservations, :status, :boolean, default: true
  end
end
