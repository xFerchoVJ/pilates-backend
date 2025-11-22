class CreateCoupons < ActiveRecord::Migration[7.2]
  def change
    create_table :coupons do |t|
      t.string :code, null: false

      t.string :discount_type, null: false, default: "percentage"
      t.string :discount_value, precision: 10, scale: 2, null: false

      t.integer :usage_limit
      t.integer :usage_limit_per_user

      t.boolean :only_new_users, default: false
      t.boolean :active, default: true

      t.datetime :starts_at
      t.datetime :ends_at

      t.jsonb :metadata

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end
