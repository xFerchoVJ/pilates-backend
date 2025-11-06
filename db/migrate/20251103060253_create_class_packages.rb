class CreateClassPackages < ActiveRecord::Migration[7.2]
  def change
    create_table :class_packages do |t|
      t.string :name, null: false
      t.text :description
      t.integer :class_count, null: false
      t.integer :price, null: false
      t.string :currency, default: "mxn", null: false
      t.boolean :status, default: true, null: false

      t.timestamps
    end
  end
end
