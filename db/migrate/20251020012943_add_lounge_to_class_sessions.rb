class AddLoungeToClassSessions < ActiveRecord::Migration[7.2]
  def change
    add_reference :class_sessions, :lounge, foreign_key: true
  end
end
