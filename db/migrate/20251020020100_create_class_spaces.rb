class CreateClassSpaces < ActiveRecord::Migration[7.2]
  def change
    create_table :class_spaces do |t|
      t.references :class_session, null: false, foreign_key: true
      t.string :label
      t.integer :x
      t.integer :y
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
