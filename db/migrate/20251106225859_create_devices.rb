class CreateDevices < ActiveRecord::Migration[7.2]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :expo_push_token

      t.timestamps
    end
  end
end
