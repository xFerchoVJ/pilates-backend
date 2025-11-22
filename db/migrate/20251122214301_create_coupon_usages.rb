class CreateCouponUsages < ActiveRecord::Migration[7.2]
  def change
    create_table :coupon_usages do |t|
      t.references :coupon, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true
      t.references :transaction, null: false, foreign_key: true
      t.jsonb :metadata

      t.timestamps
    end
    add_index :coupon_usages, [ :coupon_id, :user_id ]
  end
end
