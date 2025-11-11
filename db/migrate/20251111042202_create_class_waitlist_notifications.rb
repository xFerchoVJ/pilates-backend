class CreateClassWaitlistNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :class_waitlist_notifications do |t|
      t.references :class_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :notified_at

      t.timestamps
    end

    add_index :class_waitlist_notifications, [ :class_session_id, :user_id ], unique: true
  end
end
