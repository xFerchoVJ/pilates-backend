class AddDeletedAtToClassSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :class_sessions, :deleted_at, :datetime
    add_index :class_sessions, :deleted_at
  end
end
