class RemoveCapacityFromClassSessions < ActiveRecord::Migration[7.2]
  def change
    remove_column :class_sessions, :capacity
  end
end
