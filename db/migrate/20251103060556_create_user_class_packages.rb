class CreateUserClassPackages < ActiveRecord::Migration[7.2]
  def change
    create_table :user_class_packages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :class_package, null: false, foreign_key: true
      t.integer :remaining_classes, null: false
      t.string :status, default: "active", null: false
      t.datetime :purchased_at, null: false

      t.timestamps
    end
  end
end
