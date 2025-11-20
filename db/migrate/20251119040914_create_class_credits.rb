class CreateClassCredits < ActiveRecord::Migration[7.2]
  def change
    create_table :class_credits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true
      t.string :status, default: "unused" # unused, used
      t.datetime :used_at

      t.timestamps
    end
  end
end
