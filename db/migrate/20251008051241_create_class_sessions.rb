class CreateClassSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :class_sessions do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :capacity, null: false
      t.references :instructor, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
